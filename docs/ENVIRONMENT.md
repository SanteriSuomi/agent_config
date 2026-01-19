# AI Agent Environment

Global configuration for AI coding agents (Claude Code, OpenCode, etc.).

## Directory Structure

```
~/.agents/                     # Source of truth (git repo)
├── AGENTS.md                  # Global instructions (loaded every request)
├── agents/                    # Agent definitions
├── skills/                    # Skill definitions
│   └── learned/               # Auto-extracted knowledge (gitignored)
├── docs/                      # Reference documentation
├── commands/                  # Slash commands
└── hooks/                     # Automation hooks

<project>/.agents/             # Project overrides (optional)
```

## Symlinks

Single source of truth via symlinks:

| Source | Target |
|--------|--------|
| `~/.claude/agents` | `~/.agents/agents` |
| `~/.claude/skills` | `~/.agents/skills` |
| `~/.claude/docs` | `~/.agents/docs` |
| `~/.claude/CLAUDE.md` | `~/.agents/AGENTS.md` |
| `~/.config/opencode/agent` | `~/.agents/agents` |
| `~/.config/opencode/skill` | `~/.agents/skills` |
| `~/.config/opencode/docs` | `~/.agents/docs` |
| `~/.config/opencode/AGENTS.md` | `~/.agents/AGENTS.md` |

**Manage symlinks:** `bunx @iannuttall/dotagents` (interactive CLI)

## Available Agents

### ACE-FCA Workflow Agents

| Agent | Purpose | Spawns |
|-------|---------|--------|
| `ace-orchestrator` | Orchestrates research → plan → implement pipeline | spec-interviewer, researcher, implementer |
| `spec-interviewer` | Requirements gathering via structured Q&A | — |
| `researcher` | Documentation, best practices, codebase patterns | — |
| `implementer` | Autonomous feature implementation | code-reviewer, code-refactorer, security-auditor |

### Quality Agents

| Agent | Purpose | When Used |
|-------|---------|-----------|
| `code-reviewer` | Quality, conventions, architecture check | After implementation |
| `code-refactorer` | Simplify, remove over-engineering | After review |
| `security-auditor` | OWASP, supply chain, auth checks | When touching auth/input/deps |

## Available Skills

### Core Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `continuous-learning` | Extract reusable knowledge from sessions | Auto-triggers on discoveries |
| `context7-api` | Up-to-date library documentation | "docs for [library]" |

### Quality Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `react-best-practices` | 40+ React/Next.js performance rules | Writing React code |
| `web-design-guidelines` | 100+ accessibility/UX rules | "review my UI", "check accessibility" |
| `design-review` | Visual consistency validation | After building components |
| `ui-patterns` | UI build patterns and constraints | Building components/forms |

### Utility Skills

| Skill | Purpose |
|-------|---------|
| `worktrunk` | Git worktree management |

## ACE-FCA Pipeline

```
[User task] → ace-orchestrator
    │
    ├─→ (if unclear) spec-interviewer → SPEC.md
    │
    ├─→ researcher(s) → RESEARCH.md
    │
    ├─→ [autonomous planning] → PLAN.md
    │
    └─→ implementer → code + tests
           │
           ├─→ code-reviewer
           ├─→ code-refactorer
           └─→ security-auditor (conditional)
```

### Artifacts

| Artifact | Created By | Consumed By |
|----------|------------|-------------|
| `SPEC.md` | spec-interviewer | researcher, implementer |
| `RESEARCH.md` | researcher | implementer, ace-orchestrator |
| `PLAN.md` | ace-orchestrator | implementer |

## Continuous Learning

The `continuous-learning` skill auto-extracts reusable knowledge:

**Triggers:**
- Non-obvious debugging discoveries
- Workarounds requiring multiple attempts
- Project-specific patterns

**Output:** `~/.agents/skills/learned/<skill-name>/SKILL.md`

**Retrieval:** `researcher` agent checks learned skills before external research.

## Adding New Agents

1. Create `~/.agents/agents/<name>.md`
2. Add frontmatter:
```yaml
---
name: my-agent
description: 'Brief description for semantic matching'
allowed-tools: Read, Write, Glob, Grep, Bash
---
```
3. Write agent instructions in markdown
4. Agent auto-discovered by tools via symlinks

## Adding New Skills

1. Create `~/.agents/skills/<name>/SKILL.md`
2. Add frontmatter:
```yaml
---
name: my-skill
description: 'Trigger phrases and purpose'
---
```
3. Write skill instructions
4. Skill auto-discovered via symlinks

## External Skills

For skills from external repos, add `source` to frontmatter:

```yaml
---
name: external-skill
description: '...'
source: https://github.com/owner/repo
---
```

**Update:** `cd ~/.agents/skills/<name> && git pull`

## Project Overrides

To override global agents/skills for a project:

1. Create `<project>/.agents/` directory
2. Add overriding files with same names
3. Project-level takes precedence

## Version Control

```bash
cd ~/.agents
git status              # Check changes
git add .               # Stage all
git commit -m "..."     # Commit
git push                # Push to remote (if configured)
```

**Gitignored:** `skills/learned/` (session-specific, auto-generated)

## Troubleshooting

**Symlinks broken?**
```bash
bunx @iannuttall/dotagents  # Repair via interactive CLI
```

**Agent not recognized?**
- Check frontmatter has `name` and `description`
- Verify symlink exists: `ls -la ~/.claude/agents`

**Skill not triggering?**
- Check `description` contains trigger phrases
- Verify SKILL.md exists in skill folder
