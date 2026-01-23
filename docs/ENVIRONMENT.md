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

**Manage symlinks:** Created manually (see Troubleshooting section)

## Available Agents

| Agent | Purpose | When Used |
|-------|---------|-----------|
| `researcher` | Documentation, best practices, codebase patterns | Before implementation |
| `implementer` | Autonomous feature implementation | Feature work |
| `code-quality` | Two-pass review + refactor (merged reviewer/refactorer) | After changes, before commits |
| `security-auditor` | OWASP, supply chain, auth checks | When touching auth/input/deps |

## Available Skills

### Core Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `browser-automation` | Headless browser automation via agent-browser CLI | "go to [url]", "click", "fill form", "screenshot", "scrape" |
| `continuous-learning` | Extract reusable knowledge from sessions | Auto-triggers on discoveries |
| `context7-api` | Up-to-date library documentation | "docs for [library]" |

### Quality Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `react-best-practices` | 40+ React/Next.js performance rules | Writing React code |
| `web-ui-patterns` | Comprehensive UI build patterns | Building components/forms/layouts |
| `design-review` | Validation + accessibility audit | After building, before commit |

### Merged Skills

**`web-ui-patterns`** combines rules from multiple sources into one comprehensive skill:

| Source | Content |
|--------|---------|
| `ibelick/ui-skills` | baseline-ui, fixing-accessibility, fixing-motion-performance, fixing-metadata |
| `vercel-labs/web-interface-guidelines` | Accessibility, forms, typography, interaction rules |

**`design-review`** includes validation rules from:
- `rams.ai`
- `vercel-labs/web-interface-guidelines`

Use `web-ui-patterns` while building, `design-review` to validate.

### Utility Skills

| Skill | Purpose |
|-------|---------|
| `postgres-best-practices` | Postgres performance optimization (Supabase) |
| `logging-best-practices` | Wide events / canonical log lines pattern |
| `crafting-effective-readmes` | README templates by project type |
| `skill-judge` | Evaluate skill quality (120-point rubric) |
| `sec-context` | Security anti-patterns (MANUAL ONLY - explicit request or security-auditor) |
| `worktrunk` | Git worktree management |

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

For skills from external repos, add `source` or `sources` to frontmatter:

```yaml
---
name: external-skill
description: '...'
source: https://github.com/owner/repo
last-synced: 2026-01-23
---
```

For merged skills from multiple sources:

```yaml
---
name: merged-skill
description: '...'
sources:
  - https://github.com/owner/repo-a
  - https://github.com/owner/repo-b
merged-from:
  - skill-a (owner/repo-a)
  - skill-b (owner/repo-b)
last-synced: 2026-01-23
---
```

**Update:** Fetch latest from source URL and update `last-synced` date.

## Project Overrides

To override global agents/skills for a project:

1. Create `<project>/.agents/` directory
2. Add overriding files with same names
3. Project-level takes precedence

## Hooks

Hooks live in `~/.agents/hooks/`. Unlike skills/agents, symlinks don't work for hooks — each tool requires manual setup.

### Claude Code

Claude Code uses Git Bash on Windows. Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": ".*",
      "hooks": ["bash ~/.agents/hooks/claudeception-activator.sh"]
    }]
  }
}
```

If Git Bash unavailable, use PowerShell:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": ".*",
      "hooks": ["powershell -File ~/.agents/hooks/claudeception-activator.ps1"]
    }]
  }
}
```

### OpenCode

Copy plugin to OpenCode's plugins folder:

```bash
# Windows
copy "%USERPROFILE%\.agents\hooks\claudeception-activator.ts" "%USERPROFILE%\.config\opencode\plugins\"

# Unix/macOS
cp ~/.agents/hooks/claudeception-activator.ts ~/.config/opencode/plugins/
```

Or add to `opencode.jsonc`:

```json
{
  "plugins": ["~/.agents/hooks/claudeception-activator.ts"]
}
```

### Available Hooks

| Hook | Purpose |
|------|---------|
| `claudeception-activator` | Reminds agent to evaluate session for extractable knowledge |

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
# Windows (run as admin)
mklink /D "%USERPROFILE%\.claude\agents" "%USERPROFILE%\.agents\agents"
mklink /D "%USERPROFILE%\.claude\skills" "%USERPROFILE%\.agents\skills"
mklink /D "%USERPROFILE%\.claude\docs" "%USERPROFILE%\.agents\docs"

# Unix/macOS
ln -s ~/.agents/agents ~/.claude/agents
ln -s ~/.agents/skills ~/.claude/skills
ln -s ~/.agents/docs ~/.claude/docs
```

**Agent not recognized?**
- Check frontmatter has `name` and `description`
- Verify symlink exists: `ls -la ~/.claude/agents`

**Skill not triggering?**
- Check `description` contains trigger phrases
- Verify SKILL.md exists in skill folder
