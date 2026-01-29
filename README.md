# ~/.agents

> Last reviewed: 2026-01-29

Personal AI agent configuration for Claude Code and OpenCode. Single source of truth via symlinks.

## What's Here

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Global rules loaded every session |
| `agents/` | 4 subagents: researcher, implementer, code-quality, security-auditor |
| `skills/` | 7 auto-loading skills (browser, docs, docker, logging, readme, security) |
| `commands/` | Manual slash commands: capture-skill, pdf, skill-judge |
| `config/` | Tool configs (claude-code.json, opencode.json) |
| `inactive/` | Archived skills: design-styles/, project-specific/ |

## Why This Setup

One config, two tools. Claude Code and OpenCode have different config paths but similar formats. Symlinks point both tools to `~/.agents/`, so changes apply everywhere.

Agent/skill files use dual frontmatter — each tool reads its fields, ignores the rest.

## How to Extend

### Adding a skill

1. Create `skills/<name>/SKILL.md`
2. Add frontmatter with `name` and trigger-rich `description`
3. Skill auto-discovers via symlinks

### Adding an agent

1. Create `agents/<name>.md`
2. Add dual frontmatter (Claude Code + OpenCode fields)
3. Agent auto-discovers via symlinks

### Archiving unused skills

Move to `inactive/` — keeps history, stops auto-loading.

## Dependencies

Symlinks to `~/.claude/` and `~/.config/opencode/`. Create with admin PowerShell:

```powershell
# Claude Code
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\agents" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\commands" -Target "$env:USERPROFILE\.agents\commands"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\settings.json" -Target "$env:USERPROFILE\.agents\config\claude-code.json"

# OpenCode
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\agent" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\opencode.json" -Target "$env:USERPROFILE\.agents\config\opencode.json"
```

## Gotchas

- **Skills with `source:` frontmatter** are from external repos — check `last-synced:` before editing
- **`inactive/`** is tracked in git but skills inside don't auto-load
- **Circular symlinks** will break loading — verify with `ls -la`
- **OpenCode uses `agent/`** (singular), Claude Code uses `agents/` (plural)
