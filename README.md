# ~/agent_config

OpenCode agent configuration. Git repo at `~/agent_config/`, symlinked into `~/.config/opencode/`.

## Structure

```
~/agent_config/             # Source of truth (symlinked to ~/.config/opencode/)
├── AGENTS.md               # OpenCode entry file (loaded every session)
├── RULES.md                # Universal rules + context router (shared with Hermes)
├── agents/                 # Subagents
│   └── researcher.md       # Research: docs, APIs, best practices
├── skills/                # Auto-loading skills
│   ├── playwright-cli/    # Browser automation via Playwright
│   ├── context7-api/      # Library documentation lookup
│   ├── pm2/               # Background process management
│   └── funscript/         # NSFW script/video library organizer
├── commands/              # Slash commands (currently empty — scaffolding)
├── context/               # MiniPC knowledge base (gitignored; see RULES.md router)
│   ├── network.md, services.md, storage.md, llm.md, media.md
│   ├── credentials.md     # secrets — never commit
│   ├── user.md
│   └── memory/YYYY-MM.md  # append-only incident/change history
└── config/
    ├── opencode.json      # OpenCode configuration (tracked, no secrets)
    └── opencode.example.json  # Config template (reference)
```

## Context files

`context/` holds the Fedora media-server knowledge base (progressive disclosure via the router in AGENTS.md). The whole directory is **gitignored** — it contains the LAN topology, personal context, and credentials. It migrated from the openclaw workspace (`~/clawd/TOOLS.md`, `USER.md`, `MEMORY.md`) on 2026-09-09; agents may edit these files freely (except memory history, append-only).

## Symlinks

### OpenCode (`~/.config/opencode/`)

```bash
ln -s ~/agent_config/AGENTS.md ~/.config/opencode/AGENTS.md
ln -s ~/agent_config/agents ~/.config/opencode/agent
ln -s ~/agent_config/skills ~/.config/opencode/skills
ln -s ~/agent_config/config/opencode.json ~/.config/opencode/opencode.json
```

### Clawd context (migrated 2026-09-09)

The former clawd symlinks (`TOOLS.md`, `USER.md`, `MEMORY.md`) are gone — content lives in `context/` now (see above). `~/clawd/` originals remain untouched until openclaw is fully decommissioned.

## Setup

1. **Clone** this repo to `~/agent_config/`
2. **Create** the secrets file for MCP server auth (`config/opencode.json` references it via `{file:...}`):
   ```bash
   mkdir -p ~/.config/opencode/secrets
   echo "your_zai_api_key" > ~/.config/opencode/secrets/z_ai_api_key
   ```
   Get your [Z.AI API key](https://z.ai/manage-apikey/apikey-list) (for MCP servers: search, reader, vision, zread). Adjust the local provider URL in `config/opencode.json` if needed (or remove the `provider` block).
3. **Copy** the env template for skills that need direct API access:
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and replace:
   - `your_api_key_here` → your [Context7 API key](https://context7.com/dashboard)
4. **Create junctions** (see above)
5. **Restart** OpenCode

## Environment Variables

`config/opencode.json` is tracked (safe to share — no secrets, only `{file:...}` / `{env:...}` references). Secrets live in `~/.config/opencode/secrets/` (local, not in the repo) and are read via `{file:...}`. The `.env` file holds keys for skills making direct REST API calls (e.g., `context7-api`).

OpenCode's `{env:...}` config syntax reads from the process environment, not `.env` files.

## How to Extend

### Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter: `name`, `description`
2. Auto-discovered via symlinks

### Adding an agent

1. Create `agents/<name>.md` with OpenCode frontmatter: `description`, `mode`, `permission`
2. Auto-discovered via symlinks

### Adding a command

1. Create `commands/<name>.md` — flat file, not subdirectory
2. Use `$ARGUMENTS` for user input
3. Available as `/<name>` in the TUI

## Notes

- Agent/skill files are OpenCode format. Both tools ignore unknown frontmatter keys.
- Commands are flat `.md` files (not `SKILL.md` in subdirectories).
- `context/` is gitignored (network topology + credentials + personal data); update files freely per the AGENTS.md router, memory history is append-only.
