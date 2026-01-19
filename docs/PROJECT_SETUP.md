# Project-Level Agent Setup

How to create good project-level `.agents/` configurations.

## When to Use Project-Level Config

Use project-level `.agents/` when:
- Project has domain-specific constraints
- Custom agents needed for this project only
- Skills need project-specific behavior
- Override global agent behavior

## Directory Structure

```
<project>/.agents/
├── AGENTS.md           # Project-specific pointers
├── docs/               # Project-specific docs
├── agents/             # Project agent overrides
└── skills/             # Project-specific skills
```

## AGENTS.md Best Practices

Keep project AGENTS.md focused:

```markdown
# Project: [Name]

## Domain Context
[1-2 sentences - what this project does]

## Key Constraints
- [Constraint specific to this project]
- [Another project constraint]

## Reference Files
- Tech stack: See package.json / cargo.toml / etc.
- Design tokens: See docs/DESIGN_STYLE.md (if different from global)

## Project-Specific Patterns
- [Pattern 1]: [Brief description]
```

## Agent Overrides

To override a global agent, create same-named file in `.agents/agents/`:

```markdown
---
name: implementer
description: 'Project-specific implementer with custom constraints'
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
---

# Implementer

[Include any project-specific instructions here]

## Additional Constraints

- [Project-specific constraint]
```

## Skill Overrides

Same pattern - create folder with SKILL.md in `.agents/skills/`:

```
.agents/skills/custom-skill/
└── SKILL.md
```
