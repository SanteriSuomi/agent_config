# ~/.agents

Shared configuration for AI coding agents (Claude Code, OpenCode, etc.).

## Structure

```
~/.agents/
├── AGENTS.md           # Instructions loaded by AI agents
├── agents/             # Subagent definitions (dual-compatible)
├── skills/             # Reusable skill definitions
│   └── learned/        # Auto-extracted skills (gitignored)
└── docs/               # Style guides and conventions
```

## Setup

Both tools use symlinks to `~/.agents`. Run as admin on Windows:

### Claude Code

```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\agents" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\docs" -Target "$env:USERPROFILE\.agents\docs"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
```

### OpenCode

```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\agent" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\docs" -Target "$env:USERPROFILE\.agents\docs"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
```

## Dual Compatibility

Agent/skill files include frontmatter for both tools:

```yaml
type: subagent      # Claude Code
mode: subagent      # OpenCode
allowed-tools: ...  # Claude Code
tools:              # OpenCode
  read: true
```

Unknown fields are ignored by each tool.

## Updating

### Skills with external sources

Check `source:` and `last-synced:` in frontmatter. Update `last-synced` after pulling changes.

### Submodules

```bash
git submodule update --remote
```

## Hooks

### Claude Code
- Hook scripts in `~/.claude/hooks/`
- Configured in `~/.claude/settings.json`

### OpenCode
- Plugin files in `~/.config/opencode/plugins/`
- TypeScript/JavaScript, auto-loaded at startup

## Learned Skills

The `continuous-learning` skill extracts knowledge from sessions and saves to `skills/learned/` (gitignored).
