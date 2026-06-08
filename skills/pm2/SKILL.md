---
name: pm2
description: "Run long-lived processes (dev servers, Chrome, build watchers) in the background via pm2. Use when you need a process running asynchronously while continuing to work. Triggers: start dev server, run in background, async process, pm2, detached process, long-running task, keep server running."
---

# pm2 Process Manager

Run long-lived processes in detached mode so you can continue working
(start browser automation, inspect logs, edit files) without juggling
terminal windows.

## Why pm2

pm2 runs processes in the background with log capture, restart on crash,
and a simple CLI. Logs go to `~/.pm2/logs/<name>-*.log`. This is the
standard way to keep a dev server or Chrome instance alive during an
agent session.

On Windows Git Bash, always use `npx pm2` — `pnpm exec pm2` fails to
resolve the `.CMD` shim.

## The Wrapper Pattern

pm2 cannot execute `.cmd`/`.bat` scripts (it interprets them as Node.js).
For any project using pnpm/npm scripts, create a thin `.mjs` wrapper:

```js
// scripts/pm2-dev.mjs
import { execSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');

execSync('pnpm run dev', { stdio: 'inherit', cwd: root });
```

The wrapper resolves project root from its own location, so it works from
any cwd and in git worktrees.

## Commands

```bash
# Start a process
npx pm2 start <script> --name <name>

# View recent logs (no tail)
npx pm2 logs <name> --lines 20 --nostream

# Tail logs (live, Ctrl+C to stop)
npx pm2 logs <name>

# Check stderr only (for crash diagnosis)
npx pm2 logs <name> --err --lines 20 --nostream

# Restart (after code changes)
npx pm2 restart <name>

# Status of all processes
npx pm2 list

# Stop and remove a process
npx pm2 stop <name> && npx pm2 delete <name>

# Clear logs without stopping processes
npx pm2 flush

# Nuclear: stop the entire daemon + all processes
npx pm2 kill

# Restore processes after pm2 kill
npx pm2 resurrect

# Clean up log files manually
rm ~/.pm2/logs/<name>-*.log
```

## Common Patterns

### Dev server

```bash
npx pm2 start scripts/pm2-dev.mjs --name myapp
# Wait for startup, then verify:
npx pm2 logs myapp --lines 5 --nostream
```

### Build watcher

```bash
npx pm2 start "npx tsc --watch" --name tsc-watch
```

## Crash Prevention

pm2 auto-restarts crashed processes by default. For unstable processes
(failing builds, missing env vars, port conflicts), limit restart
thrashing:

```bash
# Cap at 5 consecutive crashes, with 3s between attempts
npx pm2 start <script> --name <name> \
  --max-restarts 5 \
  --restart-delay 3000 \
  --min-uptime 5000

# Don't restart on clean exit (exit code 0)
npx pm2 start <script> --name <name> --stop-exit-codes 0
```

`--min-uptime` sets the threshold: if a process exits before this
duration, it counts as a crash toward `--max-restarts`. Processes that
run longer are considered stable and don't count.

If a process is in a crash loop, stop it immediately:

```bash
npx pm2 stop <name>
```

## Environment Variables

`npx pm2 restart` does **not** reload `.env` changes. Options:

```bash
# Inline env var (applies immediately)
LOG_LEVEL=error npx pm2 restart <name>

# Pick up .env changes — delete and re-create
npx pm2 delete <name> && npx pm2 start <script> --name <name>
```

## Inspecting Logs

Most structured loggers emit one wide event per request/action. Look for:

- `statusCode` or `status` — HTTP response codes
- `duration_ms` or `duration` — timing
- `error` or `err` — error details
- `method`, `path` — request routing
- `requestId` or `traceId` — correlation

Use `npx pm2 logs <name> --lines N --nostream` to grab recent output,
then grep for the fields relevant to your investigation.

## Gotchas

- **Windows: SIGINT/SIGTERM don't fire** on `pm2 stop`/`restart` ([#3555](https://github.com/Unitech/pm2/issues/3555)). Use `--shutdown-with-message` flag, then handle `process.on('message', msg => { if (msg === 'shutdown') { /* cleanup */ process.exit(0); } })` in your wrapper script. Without this, processes get killed without graceful shutdown.
- **Log accumulation**: pm2 logs grow unbounded at `~/.pm2/logs/`. Use `npx pm2 flush` to clear, or install `pm2-logrotate` (`npx pm2 install pm2-logrotate`) for automatic rotation. Configure with `npx pm2 set pm2-logrotate:max_size 10M`.
- **`.env` not reloaded on restart**: Use `delete` + `start`, or set env vars inline.
- **Crash loops**: Check stderr with `--err` flag. If the process exits immediately, pm2 may restart it repeatedly — use `npx pm2 stop <name>` to break the loop. Also see [Crash Prevention](#crash-prevention).
- **`pnpm exec pm2` broken on Windows**: Use `npx pm2` or `./node_modules/.bin/pm2` instead.
- **`interpreter: 'none'` can fail on Windows**: Causes `spawn EFTYPE` for some binaries. Use the `.mjs` wrapper pattern instead.
- **Non-TTY shells**: Some CLIs (e.g., `drizzle-kit push`) use interactive prompts. Always pass `--force` or `--yes` flags when running under pm2.
