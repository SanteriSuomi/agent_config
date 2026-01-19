# ~/.agents

Shared configuration for AI coding agents (Claude Code, OpenCode, etc.).

## Structure

```
~/.agents/
├── AGENTS.md           # Instructions for AI agents
├── agents/             # Subagent definitions
│   ├── researcher.md
│   ├── implementer.md
│   ├── code-reviewer.md
│   ├── code-refactorer.md
│   ├── security-auditor.md
│   ├── spec-interviewer.md
│   └── ace-orchestrator.md
├── skills/             # Reusable skill definitions
│   ├── browser-automation/
│   ├── context7-api/
│   ├── continuous-learning/  (submodule)
│   ├── design-review/
│   ├── ui-patterns/
│   ├── web-design-guidelines/
│   ├── react-best-practices/
│   ├── worktrunk/
│   └── learned/        # Auto-extracted skills (gitignored)
└── docs/               # Style guides and conventions
    ├── CODE_STYLE.md
    ├── COMMIT_STYLE.md
    ├── DESIGN_STYLE.md
    └── ...
```

## Setup

### Claude Code

Add to `~/.claude/CLAUDE.md`:
```markdown
Contents of ~/.agents/AGENTS.md are included automatically.
```

Skills are discovered from `~/.claude/skills/` or symlinked.

### OpenCode

Symlink to OpenCode config:
```powershell
# Run as admin
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\agent" -Target "$env:USERPROFILE\.agents\agents"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\skills" -Target "$env:USERPROFILE\.agents\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\docs" -Target "$env:USERPROFILE\.agents\docs"
```

## Agents vs Skills

| Type | Purpose | Invocation |
|------|---------|------------|
| **Agents** | Autonomous task executors with specific roles | Claude: `Task` tool, OpenCode: `@agent-name` |
| **Skills** | Reusable instructions/knowledge | Loaded automatically when relevant |

## Dual Compatibility

Agent files include both Claude Code and OpenCode frontmatter:
```yaml
---
name: researcher
type: subagent      # Claude Code
mode: subagent      # OpenCode
description: "..."
allowed-tools: ...  # Claude Code
tools:              # OpenCode
  read: true
  ...
---
```

## Updating Skills with External Sources

Skills with `source:` field track upstream repos. Check `last-synced:` date.

```yaml
source: https://github.com/org/repo/...
last-synced: 2026-01-19
```

## Learned Skills

The `continuous-learning` skill (Claudeception) extracts knowledge from sessions and saves to `skills/learned/`. This directory is gitignored.
