---
name: skill-judge
description: "Evaluate Agent Skill design quality against official specifications. Use when reviewing, auditing, or improving SKILL.md files. Provides multi-dimensional scoring (120 points) and actionable improvements. Triggers: evaluate skill, review skill, audit skill, skill quality."
source: https://github.com/softaworks/agent-toolkit/tree/main/skills/skill-judge
last-synced: 2026-01-23
metadata:
  author: softaworks
  version: "1.0.0"
---

# Skill Judge

Evaluate Agent Skills against official specifications and patterns.

---

## Core Formula

> **Good Skill = Expert-only Knowledge − What Claude Already Knows**

A Skill's value is the **knowledge delta** — what it provides beyond what the model already knows.

### Three Types of Knowledge

| Type | Definition | Treatment |
|------|------------|-----------|
| **Expert** | Claude genuinely doesn't know this | Must keep — this is the Skill's value |
| **Activation** | Claude knows but may not think of | Keep if brief — serves as reminder |
| **Redundant** | Claude definitely knows this | Delete — wastes tokens |

**Target ratio**: >70% Expert, <20% Activation, <10% Redundant

---

## Evaluation Dimensions (120 points)

### D1: Knowledge Delta (20 pts) — THE CORE

| Score | Criteria |
|-------|----------|
| 0-5 | Explains basics Claude knows |
| 6-10 | Mixed: some expert knowledge diluted by obvious content |
| 11-15 | Mostly expert knowledge with minimal redundancy |
| 16-20 | Pure knowledge delta — every paragraph earns its tokens |

**Red flags** (instant ≤5): "What is [basic concept]", step-by-step tutorials, generic best practices

**Green flags**: Decision trees, trade-offs only experts know, edge cases, "NEVER do X because [non-obvious reason]"

### D2: Mindset + Procedures (15 pts)

Does it transfer expert thinking patterns AND domain-specific procedures Claude wouldn't know?

| Type | Value |
|------|-------|
| Thinking patterns ("Before X, ask...") | High |
| Domain-specific procedures | High |
| Generic procedures (open, edit, save) | Low — delete |

### D3: Anti-Pattern Quality (15 pts)

| Score | Criteria |
|-------|----------|
| 0-3 | No anti-patterns |
| 4-7 | Generic warnings ("avoid errors") |
| 8-11 | Specific NEVER list with some reasoning |
| 12-15 | Expert-grade anti-patterns with WHY |

### D4: Specification — ESPECIALLY Description (15 pts)

**Description is THE MOST IMPORTANT field** — determines if skill gets used at all.

Must answer:
1. **WHAT**: What does this Skill do?
2. **WHEN**: In what situations should it be used?
3. **KEYWORDS**: What terms should trigger it?

### D5: Progressive Disclosure (15 pts)

| Layer | Content | Size |
|-------|---------|------|
| 1: Metadata | name + description | ~100 tokens |
| 2: SKILL.md | Guidelines, examples | <500 lines |
| 3: Resources | scripts/, references/ | On demand |

### D6: Freedom Calibration (15 pts)

| Task Type | Freedom | Why |
|-----------|---------|-----|
| Creative/Design | High | Multiple valid approaches |
| Code review | Medium | Principles + judgment |
| File format ops | Low | One wrong byte corrupts |

### D7: Pattern Recognition (10 pts)

| Pattern | ~Lines | Use When |
|---------|--------|----------|
| Mindset | ~50 | Creative tasks requiring taste |
| Navigation | ~30 | Multiple distinct scenarios |
| Philosophy | ~150 | Art/creation requiring originality |
| Process | ~200 | Complex multi-step projects |
| Tool | ~300 | Precise operations on formats |

### D8: Practical Usability (15 pts)

- Decision trees for multi-path scenarios
- Working code examples
- Error handling and fallbacks
- Edge cases covered

---

## NEVER Do When Evaluating

- Give high scores just because it "looks professional"
- Ignore token waste
- Let length impress you
- Skip mentally testing decision trees
- Forgive explaining basics with "helpful context"
- Overlook missing anti-patterns
- Assume all procedures are valuable
- Undervalue the description field
- Put "when to use" only in body (Agent only sees description before loading)

---

## Common Failure Patterns

| Pattern | Symptom | Fix |
|---------|---------|-----|
| Tutorial | Explains basics | Delete — Claude knows this |
| Dump | 800+ lines | Progressive disclosure |
| Orphan References | Files never loaded | Add MANDATORY triggers |
| Checkbox Procedure | Step 1, 2, 3... | Transform to thinking frameworks |
| Vague Warning | "Be careful" | Specific NEVER + WHY |
| Invisible Skill | Never activated | Fix description: WHAT + WHEN + KEYWORDS |
| Wrong Location | "When to use" in body | Move to description |
| Over-Engineered | README, CHANGELOG, etc. | Delete auxiliary files |

---

## Quick Checklist

```
KNOWLEDGE DELTA:
[ ] No "What is X" for basic concepts
[ ] No tutorials for standard operations
[ ] Has decision trees for non-obvious choices
[ ] Has trade-offs only experts know

ANTI-PATTERNS:
[ ] Has explicit NEVER list
[ ] Specific, not vague
[ ] Includes WHY

DESCRIPTION (critical):
[ ] Answers WHAT it does
[ ] Answers WHEN to use
[ ] Contains trigger KEYWORDS

STRUCTURE:
[ ] SKILL.md < 500 lines
[ ] Loading triggers if references exist

USABILITY:
[ ] Decision trees for multi-path
[ ] Error handling and fallbacks
```

---

## Grade Scale

| Grade | Score | Meaning |
|-------|-------|---------|
| A | 108+ (90%) | Production-ready |
| B | 96-107 (80%) | Minor improvements |
| C | 84-95 (70%) | Clear improvement path |
| D | 72-83 (60%) | Significant issues |
| F | <72 (<60%) | Needs redesign |
