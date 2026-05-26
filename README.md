# ~/agent_config

OpenCode agent configuration. Git repo at `~/agent_config/`, symlinked into `~/.config/opencode/`.

## Structure

```
~/agent_config/             # Source of truth (symlinked to ~/.config/opencode/)
├── AGENTS.md               # Global rules loaded every session
├── agents/                 # Subagents
│   ├── researcher.md       # Research: docs, APIs, best practices
│   └── security-auditor.md # Security: OWASP, dependency audits
├── skills/                 # Auto-loading skills
│   ├── browser-automation/ # Browser testing via agent-browser
│   ├── context7-api/       # Library documentation lookup
│   └── security/           # Security anti-patterns (25+ CWE refs)
├── commands/               # Slash commands
│   ├── commit.md           # /commit — analyze diff, create commit
│   ├── pr.md               # /pr — create pull request
│   ├── debug.md            # /debug — trace errors to root cause
│   └── review.md           # /review — review uncommitted changes
├── config/
│   └── opencode.json       # OpenCode configuration (gitignored, see setup)
├── TOOLS.md → ~/clawd/     # Service ports, paths, GPU, network (on-demand)
├── USER.md → ~/clawd/      # About the user (on-demand)
└── MEMORY.md → ~/clawd/    # Long-term memory, hard rules, infra history (on-demand)
```

## Symlinks

### OpenCode (`~/.config/opencode/`)

```bash
ln -s ~/agent_config/AGENTS.md ~/.config/opencode/AGENTS.md
ln -s ~/agent_config/agents ~/.config/opencode/agent
ln -s ~/agent_config/skills ~/.config/opencode/skills
ln -s ~/agent_config/config/opencode.json ~/.config/opencode/opencode.json
```

### Clawd context (one-way, read-only from OpenCode)

```bash
ln -s ~/clawd/TOOLS.md ~/agent_config/TOOLS.md
ln -s ~/clawd/USER.md ~/agent_config/USER.md
ln -s ~/clawd/MEMORY.md ~/agent_config/MEMORY.md
```

These files are owned by Clawdbot (`~/clawd/`). OpenCode reads them on-demand (progressive disclosure) but never writes to them.

## Setup

1. **Clone** this repo to `~/agent_config/`
2. **Copy** the config template and add your API keys:
   ```bash
   cp config/opencode.example.json config/opencode.json
   ```
   Then edit `config/opencode.json` and replace:
   - `your_zai_api_key_here` → your [Z.AI API key](https://z.ai/manage-apikey/apikey-list) (for MCP servers: search, reader, vision, zread)
   - `http://your_local_ip:8525/v1` → your local inference server URL (or remove the `provider` block)
3. **Copy** the env template for skills that need direct API access:
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and replace:
   - `your_api_key_here` → your [Context7 API key](https://context7.com/dashboard)
4. **Create symlinks** (see above)
5. **Restart** OpenCode

## Environment Variables

API keys for MCP servers live in `config/opencode.json` (gitignored). The `.env` file is used only by skills that make direct REST API calls (e.g., `context7-api`).

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
- The `security` skill is loaded on-demand by the `security-auditor` agent via `skill({ name: "security" })`.
- Clawd context files (TOOLS.md, USER.md, MEMORY.md) are symlinks — gitignored, read-only from OpenCode.
