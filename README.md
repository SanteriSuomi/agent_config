# ~/.agents

Personal AI agent configuration. Single source of truth via junctions to `~/.config/opencode/` and `~/.claude/`.

## Structure

```
~/.agents/
├── AGENTS.md              # Global rules loaded every session
├── agents/                # Subagents
│   ├── researcher.md      # Research: docs, APIs, best practices
│   └── security-auditor.md # Security: OWASP, dependency audits
├── skills/                # Auto-loading skills
│   ├── browser-automation/ # Browser testing via agent-browser
│   ├── context7-api/      # Library documentation lookup
│   └── security/          # Security anti-patterns (25+ CWE refs)
├── commands/              # Slash commands
│   ├── commit.md          # /commit — analyze diff, create commit
│   ├── pr.md              # /pr — create pull request
│   ├── debug.md           # /debug — trace errors to root cause
│   └── review.md          # /review — review uncommitted changes
└── config/
    └── opencode.json      # OpenCode configuration
```

## Junctions

Both `~/.config/opencode/` and `~/.claude/` junction to `~/.agents/` for `agents/`, `skills/`, and `commands/`. Create with admin PowerShell:

```powershell
# OpenCode
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\agents" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\commands" -Target "$env:USERPROFILE\.agents\commands"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\opencode.json" -Target "$env:USERPROFILE\.agents\config\opencode.json"

# Claude Code
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\agents" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\commands" -Target "$env:USERPROFILE\.agents\commands"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
```

## How to Extend

### Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter: `name`, `description`
2. Auto-discovered via junctions

### Adding an agent

1. Create `agents/<name>.md` with OpenCode frontmatter: `description`, `mode`, `permission`
2. Auto-discovered via junctions

### Adding a command

1. Create `commands/<name>.md` — flat file, not subdirectory
2. Use `$ARGUMENTS` for user input
3. Available as `/<name>` in the TUI

## Notes

- Agent/skill files are OpenCode format. Both tools ignore unknown frontmatter keys.
- Commands are flat `.md` files (not `SKILL.md` in subdirectories).
- The `security` skill is loaded on-demand by the `security-auditor` agent via `skill({ name: "security" })`.
