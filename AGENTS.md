# AGENTS.md

OpenCode entry file. **Universal behavioral rules live in `RULES.md` (same directory) — read and follow it every session.** This file holds OpenCode-specific configuration only.

## Environment

```
~/agent_config/             # Source of truth (symlinked to ~/.config/opencode/)
├── AGENTS.md               # This file (loaded every session)
├── RULES.md                # Universal rules, shared with Hermes
├── agents/                 # Subagents: researcher
├── skills/                 # Auto-loading skills: playwright-cli, context7-api, pm2, funscript, searxng, web-reader, gh-repos, zomboid
├── commands/               # Slash commands (currently empty — scaffolding)
├── context/                # Shared knowledge base (see Context Router in RULES.md)
└── config/                 # Tool configs: opencode.json (MCP servers, providers)
```

> On Windows the source-of-truth dir is `~/.agents/` instead of `~/agent_config/`; symlink layout into `~/.config/opencode/` is identical.

**IMPORTANT:** Always modify files in the source-of-truth dir (`~/agent_config/` on Fedora, `~/.agents/` on Windows) — never directly in `~/.config/opencode/`. Symlinks ensure changes propagate automatically.

**Environment variables:** `config/opencode.json` is tracked (safe to share — no secrets, only `{file:...}` / `{env:...}` references). Secrets live in `~/.config/opencode/secrets/` (local, not in the repo) and are read via `{file:...}`. The `.env` file holds keys for skills making direct REST API calls (e.g., `context7-api`) and is loaded into the process env. OpenCode's `{env:...}` config syntax reads from the process environment, not `.env` files.

**Platforms:** Windows (main host); Linux/Fedora (MiniPC).

## Tool Precedence

Prefer built-in capabilities over MCP servers; fall back to MCP only when the built-in is unavailable or fails:

- **Vision:** read images natively via the llama-server-windows (or llama-server-linux) model currently running (mmproj attached, `attachment: true`). If the active model is text-only (e.g. lmstudio), switch to a llama-server model for image work. No external vision APIs.
- **Web search:** `searxng` skill first (self-hosted, no API keys); `web-search-prime` MCP only as fallback. Built-in websearch is disabled (hardwired to hosted Exa/Parallel).
- **Web reading:** built-in `webfetch` for quick checks and images; `web-reader` skill (trafilatura) for article-class reads needing clean extraction. `web-reader` MCP only as fallback.
- **GitHub repos:** `gh-repos` skill (gh CLI, always-current); deep source exploration → scout subagent.
- Shared web-research conventions (source register, date stamping, URL discipline): `references/web-research.md` in this repo.
- When a built-in attempt fails, say so briefly before using the MCP fallback.

## Context Management

Use subagents for exploration and research — do not consume main context with discovery work. **Explore agent** for codebase navigation, **researcher agent** for web searches, documentation, and API references. Only run grep/glob/websearch directly when the query is trivial (single file, known path) or needed immediately for an in-progress decision.
