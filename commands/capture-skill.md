# Capture Skill

Extract learnings from conversation and create quality skills. Invoke with `/capture-skill`.

$ARGUMENTS

---

## Core Formula

> **Good Skill = Expert-only Knowledge − What Claude Already Knows**

Before writing anything, ask: "Would Claude know this without the skill?"

---

## Phase 1: Identify Learnings

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

---

## Phase 2: Determine Destination

```
Is this project-specific?
├── Yes → ~/.agents/inactive/project-specific/
└── No
    ├── General tool/pattern → ~/.agents/skills/
    └── Design system → ~/.agents/inactive/design-styles/
```

New skill or update existing?
- Check `~/.agents/skills/` for related skills first
- Prefer updating over creating duplicates

---

## Phase 3: Draft with Quality Standards

### Description (CRITICAL)

Must answer in <100 tokens:
1. **WHAT**: What does this skill do?
2. **WHEN**: Situations to use it (AUTO-LOAD triggers)
3. **KEYWORDS**: Terms that should activate it

```yaml
# Bad
description: "Helps with database stuff"

# Good
description: "PostgreSQL query optimization. AUTO-LOAD when: slow queries, EXPLAIN ANALYZE, index selection, query planning. Triggers: postgres performance, slow query, sequential scan, index not used."
```

### Content Rules

| Include | Exclude |
|---------|---------|
| Decision trees | "What is X" explanations |
| Expert trade-offs | Generic best practices |
| NEVER + WHY | Vague warnings ("be careful") |
| Edge cases | Step-by-step tutorials |
| Working examples | Conversation artifacts |

### Anti-Patterns Section

Every skill should have explicit anti-patterns:

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

## Phase 4: Self-Evaluate

Before saving, score against these dimensions:

### Quick Checklist

```
KNOWLEDGE DELTA (most important):
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
[ ] Progressive disclosure if complex
```

### Grade Thresholds

| Grade | Meaning |
|-------|---------|
| A (90%+) | Ready to save |
| B (80%+) | Minor polish needed |
| C (70%+) | Revise before saving |
| <C | Don't save — needs redesign |

---

## Phase 5: Save

1. Create directory: `mkdir -p ~/.agents/skills/{skill-name}`
2. Write SKILL.md with frontmatter:

```yaml
---
name: skill-name
description: "WHAT. AUTO-LOAD when: WHEN. Triggers: KEYWORDS."
---
```

3. Verify: Read back and confirm <500 lines

---

## Edge Cases

### Multi-topic conversation
→ Suggest separate skills, don't combine unrelated learnings

### Too small for skill
→ Consider adding to AGENTS.md or project's CLAUDE.md instead

### Already exists
→ Update existing skill, don't duplicate

### Very large (>500 lines)
→ Split into SKILL.md (index) + references/ (details)

---

## Example Transformation

**Conversation artifact:**
> "After trying X, Y, and Z, I found that the issue was actually caused by A. The fix was to do B before C, making sure to never do D because it causes E."

**Distilled skill content:**
```markdown
## Workflow

1. Do B before C
2. Verify with [check]

## NEVER

- **Don't do D** — causes E (even when F seems fine)

## Common Issue

If [symptom], the cause is usually A, not X/Y/Z.
```

Note: Failed attempts (X, Y, Z) are omitted. Only the working solution and the gotcha are preserved.
