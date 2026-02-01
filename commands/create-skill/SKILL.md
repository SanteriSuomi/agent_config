# Skillsmith

Create, capture, and evaluate agent skills. Invoke with `/skillsmith`.

$ARGUMENTS

---

## Core Formula

> **Good Skill = Expert-only Knowledge − What Claude Already Knows**

A Skill's value is the **knowledge delta** — what it provides beyond what the model already knows.

---

## Modes

Detect mode from arguments:

| Input | Mode |
|-------|------|
| No args | **Capture** — extract from conversation |
| Description/topic | **Create** — generate from scratch |
| Path to existing skill | **Evaluate** — judge quality |

---

## Mode: Capture

Extract learnings from current conversation.

### Phase 1: Identify Learnings

Scan conversation for:

| Type | Example | Worth Capturing? |
|------|---------|------------------|
| **Workflow** | Multi-step process that worked | Yes |
| **Gotcha** | Non-obvious failure mode | Yes |
| **Decision** | Trade-off reasoning | Yes |
| **Pattern** | Reusable code/approach | Yes |
| **Domain fact** | Expert knowledge | Yes |
| **Basic how-to** | Standard operations | No — Claude knows |
| **One-off fix** | Won't recur | No |

**Extract the final working approach, not the failed attempts.**

### Phase 2: Determine Destination

```
Is this project-specific?
├── Yes → ~/.agents/inactive/project-specific/
└── No
    ├── General tool/pattern → ~/.agents/skills/
    └── Design system → ~/.agents/inactive/design-styles/
```

Check `~/.agents/skills/` for related skills first. Prefer updating over creating duplicates.

---

## Mode: Create

Generate skill from description/topic.

### Phase 1: Research

1. Identify what Claude already knows about the topic
2. Search web for expert-level knowledge, edge cases, anti-patterns
3. Find decision frameworks experts use

### Phase 2: Extract Delta

Focus on:
- Trade-offs only experts know
- Non-obvious failure modes
- Decision trees for choosing approaches
- "NEVER do X because Y" rules

Skip:
- Basic definitions
- Standard tutorials
- Generic best practices

---

## Mode: Evaluate

Judge an existing skill against quality standards.

### Knowledge Types

| Type | Definition | Treatment |
|------|------------|-----------|
| **Expert** | Claude genuinely doesn't know | Must keep — this is value |
| **Activation** | Claude knows but may not think of | Keep if brief |
| **Redundant** | Claude definitely knows | Delete |

**Target ratio**: >70% Expert, <20% Activation, <10% Redundant

### Scoring (120 pts)

| Dimension | Points | Key Criteria |
|-----------|--------|--------------|
| Knowledge Delta | 20 | Pure expert knowledge, no basics |
| Mindset + Procedures | 15 | Thinking patterns, not generic steps |
| Anti-Pattern Quality | 15 | Specific NEVER + WHY |
| Description | 15 | WHAT + WHEN + KEYWORDS |
| Progressive Disclosure | 15 | <500 lines, references on demand |
| Freedom Calibration | 15 | Matches task type |
| Pattern Recognition | 10 | Correct structure for content |
| Practical Usability | 15 | Decision trees, examples |

### Grades

| Grade | Score | Meaning |
|-------|-------|---------|
| A | 108+ (90%) | Production-ready |
| B | 96-107 (80%) | Minor improvements |
| C | 84-95 (70%) | Clear improvement path |
| D | 72-83 (60%) | Significant issues |
| F | <72 | Needs redesign |

---

## Writing Standards (All Modes)

### Description (CRITICAL)

Must answer in <100 tokens:
1. **WHAT**: What does this skill do?
2. **WHEN**: Situations to use it (AUTO-LOAD triggers)
3. **KEYWORDS**: Terms that should activate it

```yaml
# Bad
description: "Helps with database stuff"

# Good
description: "PostgreSQL query optimization. AUTO-LOAD when: slow queries, EXPLAIN ANALYZE, index selection. Triggers: postgres performance, slow query, sequential scan."
```

### Content Rules

| Include | Exclude |
|---------|---------|
| Decision trees | "What is X" explanations |
| Expert trade-offs | Generic best practices |
| NEVER + WHY | Vague warnings |
| Edge cases | Step-by-step tutorials |
| Working examples | Conversation artifacts |

### Anti-Patterns Section

Every skill needs explicit anti-patterns:

```markdown
## NEVER

- **Don't X** — because Y (non-obvious reason)
- **Don't Z** — causes W in edge case
```

### Structure

```
skill-name/
├── SKILL.md       # <500 lines, main content
└── references/    # Optional, for >500 lines
    └── details.md # Loaded on demand
```

---

## Self-Evaluation Checklist

Run before saving any skill:

```
KNOWLEDGE DELTA:
[ ] No "What is X" for basic concepts
[ ] No tutorials for standard operations
[ ] Has decision trees for non-obvious choices
[ ] Has trade-offs only experts know
[ ] >70% expert knowledge, <10% redundant

ANTI-PATTERNS:
[ ] Has explicit NEVER list
[ ] Specific, not vague
[ ] Includes WHY

DESCRIPTION:
[ ] Answers WHAT it does
[ ] Answers WHEN to use (triggers)
[ ] Contains trigger KEYWORDS
[ ] <100 tokens

STRUCTURE:
[ ] SKILL.md < 500 lines
[ ] Loading triggers if references exist
```

---

## Common Failures

| Pattern | Symptom | Fix |
|---------|---------|-----|
| Tutorial | Explains basics | Delete — Claude knows |
| Dump | 800+ lines | Progressive disclosure |
| Vague Warning | "Be careful" | Specific NEVER + WHY |
| Invisible Skill | Never activated | Fix description |
| Wrong Location | "When to use" in body | Move to description |

---

## Save Location

```yaml
---
name: skill-name
description: "WHAT. AUTO-LOAD when: WHEN. Triggers: KEYWORDS."
---
```

Save to: `~/.agents/skills/{skill-name}/SKILL.md`
