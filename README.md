# ~/.agents

> Last reviewed: 2026-01-27

Shared AI agent configuration for Claude Code and OpenCode. Single source of truth via symlinks.

## What's Here

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Global rules loaded every session (67 lines) |
| `agents/` | 4 subagents: researcher, implementer, code-quality, security-auditor |
| `skills/` | 11 auto-loading skills (UI, backend, security, tools) |
| `skills/.unused/` | Archived skills (worktrunk, skill-judge) |
| `commands/` | Manual slash commands (skill-judge) |

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

Move to `skills/.unused/` — keeps history, stops auto-loading.

## Dependencies

Symlinks to `~/.claude/` and `~/.config/opencode/`. Create with admin PowerShell:

```powershell
# Claude Code
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\agents" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\commands" -Target "$env:USERPROFILE\.agents\commands"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"

# OpenCode
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\agent" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
```

## Gotchas

- **Skills with `source:` frontmatter** are from external repos — check `last-synced:` before editing
- **`skills/.unused/`** is tracked in git but skills inside don't auto-load
- **Circular symlinks** will break loading — verify with `ls -la`
- **OpenCode uses `agent/`** (singular), Claude Code uses `agents/` (plural)

## Related

- [Claude Code Skills Docs](https://docs.anthropic.com/en/docs/claude-code/skills)
- [OpenCode Skills Docs](https://opencode.ai/docs/skills)
- [AGENTS.md Specification](https://agents.md/)
