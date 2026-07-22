# AGENTS.md

Global rules for AI agents. Be concise — minimal code, minimal prose, minimal steps.

## Environment

```
~/agent_config/             # Source of truth (symlinked to ~/.config/opencode/)
├── AGENTS.md               # This file (loaded every session)
├── agents/                 # Subagents: researcher
├── skills/                 # Auto-loading skills: playwright-cli, context7-api, pm2, funscript
├── commands/               # Slash commands (currently empty — scaffolding)
└── config/                 # Tool configs: opencode.json (MCP servers, providers)
```

> On Windows the source-of-truth dir is `~/.agents/` instead of `~/agent_config/`; symlink layout into `~/.config/opencode/` is identical.

**IMPORTANT:** Always modify files in the source-of-truth dir (`~/agent_config/` on Fedora, `~/.agents/` on Windows) — never directly in `~/.config/opencode/`. Symlinks ensure changes propagate automatically.

**Environment variables:** `config/opencode.json` is tracked (safe to share — no secrets, only `{file:...}` / `{env:...}` references). Secrets live in `~/.config/opencode/secrets/` (local, not in the repo) and are read via `{file:...}`. The `.env` file holds keys for skills making direct REST API calls (e.g., `context7-api`) and is loaded into the process env. OpenCode's `{env:...}` config syntax reads from the process environment, not `.env` files.

**Platforms:** Windows (main host); Linux/Fedora (MiniPC).

## Code

- Show full file paths when in git worktrees or similar
- Explicit named imports, no wildcards or barrel files
- Case-sensitive paths always
- Strict mode, type-safe code
- Types must accurately reflect reality (optional fields should be `?`, nullable fields should include `| null`)
- Omit explicit return types unless needed for clarity or compiler requirements
- Pin exact dependency versions: `"1.8.0"` not `"^1.8.0"`. Let lockfiles handle reproducibility.
- Pin exact versions in Dockerfiles and install scripts (e.g. `ansible-core==2.20.4`, `sops-v3.13.1`). Verify latest stable version via web search before pinning.

## Comments

**Only for:** exotic functions, workarounds, complex algorithms, "why" explanations.
**Never:** obvious code, redundant descriptions.

## Commits

- Imperative form ("Add feature" not "Added feature")
- Only commit when explicitly asked
- Run tests/lint first
- NEVER add watermarks, signatures, or "Co-Authored-By" lines
- **One commit per branch/PR** — squash all work into a single commit before pushing. Amend as work progresses. Unless explicitly told otherwise, never leave multiple commits on a feature branch.

## Git

- Prefer `git pull --rebase` over `git pull` to avoid merge commits

## Testing

After changes, run in order (fail fast):
1. Type check → 2. Lint → 3. Unit tests → 4. Integration tests

For browser automation, use the `playwright-cli` skill. Always use named sessions (`-s=<name>`) for isolation when multiple agents may run in parallel.

## Anti-Patterns

- Only make requested changes
- No unrequested features or refactoring
- No abstractions for one-time operations
- No error handling for impossible cases
- No hypothetical future design
- Three similar lines > premature abstraction

## Writing (Anti-Slop)

**Avoid:** throat-clearing ("In order to..."), emphasis crutches ("significantly"), tripling (always 3 items), AI words (delve, crucial, leverage, utilize, seamless, robust).

**Do:** Be specific, direct, varied rhythm. Have opinions. Acknowledge uncertainty.

## Web Search

Use current year (2026) in all searches.

## Context Management

Use subagents for exploration and research — do not consume main context with discovery work. **Explore agent** for codebase navigation, **researcher agent** for web searches, documentation, and API references. Only run grep/glob/websearch directly when the query is trivial (single file, known path) or needed immediately for an in-progress decision.

## Boundaries

**Always:** Use design-style for UI, run tests before commits, read files before modifying
**Ask First:** New dependencies, major refactors, architecture changes, deleting files
**Never:** Commit secrets, force push main, guess file contents, fabricate tool results

## Shared Context (from Clawdbot) — MiniPC only

Symlinks to `~/clawd/` workspace. Read-only — do not edit from OpenCode.

- `TOOLS.md` — read when working with services, ports, paths, GPU, network, Docker
- `USER.md` — read when personal context about Santeri is relevant
- `MEMORY.md` — read when infrastructure history, hard rules, or past incidents matter

Do not load these at session start. Only read when the task requires it.
