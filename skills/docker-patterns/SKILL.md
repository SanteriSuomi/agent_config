---
name: docker-patterns
description: "Docker best practices and optimization. AUTO-LOAD when: writing Dockerfiles, docker-compose, container security, multi-stage builds, image optimization. Triggers: 'optimize dockerfile', 'docker security', 'multi-stage build', 'container', 'docker-compose', 'image size'."
---

> **Expert patterns only. Skip basics Claude already knows.**

## Decision Trees

### Multi-Stage vs Single Stage

```
NEED multi-stage when:
├── Compiled language (Go, Rust, C) → YES, always
├── Build tools differ from runtime → YES
├── npm/pip dev dependencies → YES
├── Image >100MB for simple app → probably YES
└── Source code shouldn't ship → YES

SKIP multi-stage when:
├── Interpreted + minimal deps + no build step
└── Dev/debug image needing build tools
```

### Base Image Selection

```
scratch       → Go/Rust static binaries only, ~0MB, no shell/debug
distroless    → Java/Python/Node prod, ~20-50MB, no shell, use :debug variant
alpine        → Need package manager, GOTCHA: musl breaks glibc binaries
debian-slim   → Need glibc compat, larger but fewer surprises
dhi.io/*      → Docker Hardened Images (2026), 95% less attack surface
```

## Anti-Patterns with WHY

| Anti-Pattern | Why | Fix |
|--------------|-----|-----|
| Separate `apt-get update` | Cache goes stale, installs fail weeks later | Single RUN with `&& rm -rf /var/lib/apt/lists/*` |
| `ENV SECRET=...` | Persists in layer history forever, `unset` doesn't help | Use `--mount=type=secret` |
| Pipes without `set -o pipefail` | `curl fail \| bash` exits 0 if bash succeeds | Add `set -o pipefail &&` |
| ARG at top of Dockerfile | Changing value invalidates everything below | Put ARG late, before usage only |
| `COPY . /app` before deps | Any source change reinstalls deps | Copy lockfile first, then source |
| `FROM node:latest` | Different image each build | Pin version + digest for supply chain |
| `ADD` for local files | Can auto-extract tarballs unexpectedly | Use `COPY` |

## Cache Optimization (BuildKit)

```dockerfile
# pip cache
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# npm cache
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# apt cache
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y curl
```

Cache persists across builds even when layer invalidates.

## Signal Handling (Critical)

```dockerfile
# BAD: Shell eats SIGTERM, container gets SIGKILL after timeout
ENTRYPOINT /start.sh

# GOOD: exec replaces shell, app is PID 1
ENTRYPOINT ["/docker-entrypoint.sh"]
```

```bash
#!/bin/sh
set -e
# init...
exec "$@"  # App becomes PID 1, gets signals
```

## Security Hardening

### Mandatory

```dockerfile
# Non-root with high UID (>10000 avoids host collision)
RUN useradd -u 10001 -r -g 0 -s /sbin/nologin app
USER app
```

### Production Compose

```yaml
services:
  app:
    read_only: true                    # Deny writes by default
    tmpfs: [/tmp, /var/run]           # Grant exceptions
    security_opt:
      - no-new-privileges:true
    ports:
      - "127.0.0.1:8080:8080"         # Localhost only, not 0.0.0.0
```

### Never

```yaml
# Docker socket = full root access to host
volumes:
  - /var/run/docker.sock:/var/run/docker.sock  # NEVER in prod
```

```bash
docker run --privileged  # NEVER, use --cap-add for specific caps only
```

## Compose Patterns

### Health-Based Dependencies

```yaml
services:
  db:
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
      retries: 5

  app:
    depends_on:
      db:
        condition: service_healthy  # Wait for ready, not just started
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

## HEALTHCHECK Without curl

```dockerfile
# BAD: Adds curl + attack surface
HEALTHCHECK CMD curl -f http://localhost/health

# GOOD: Native binary or language runtime
COPY --from=builder /healthcheck /healthcheck
HEALTHCHECK CMD ["/healthcheck"]
```

## .dockerignore (Required)

```
.git
node_modules
*.log
.env*
Dockerfile*
docker-compose*
.dockerignore
__pycache__
*.pyc
.pytest_cache
coverage
dist
build
```

Without this, sends GB to daemon and may leak secrets.
