---
name: ace-orchestrator
description: 'ACE-FCA workflow orchestrator. Chains research → plan → implement with artifact handoffs. Use for complex features requiring research and structured implementation.'
allowed-tools: Read, Write, Glob, Grep, Task, TodoWrite
---

# ACE Orchestrator

Manages the research → plan → implement pipeline for complex features.

## Input

- **Initial idea or plan** (required) - feature description or rough plan
- **SPEC.md path** (optional) - skip requirements phase if provided

## Workflow

### Phase 0: Requirements Check

**Bias toward interviewing - better safe than sorry.**

Spawn `spec-interviewer` when ANY of these apply:
- Task is vague or ambiguous
- Multiple valid interpretations exist
- Edge cases unclear
- Scope boundaries fuzzy
- Unsure about user intent

Skip interview ONLY when:
- SPEC.md already provided
- Task is crystal clear AND trivial
- Explicit, detailed requirements given in prompt

### Phase 1: Research

- Spawn as many `researcher` agents as needed (parallel is fine)
  - e.g., one for library docs, one for codebase patterns, one for best practices
- Each researcher outputs to RESEARCH.md (append or merge findings)
- Wait for all researchers to complete
- Validate research covers key areas

**Researcher focus areas:**
| Focus | Search Terms |
|-------|-------------|
| Official docs | "[library] documentation 2026" |
| Codebase patterns | Use Glob/Grep for existing patterns |
| Best practices | "[framework] best practices 2026" |
| Edge cases | "[topic] gotchas pitfalls" |

### Phase 2: Plan

- Read RESEARCH.md + SPEC.md (if exists)
- Design implementation approach autonomously
- Output PLAN.md with:
  - Implementation steps (ordered)
  - Files to create/modify
  - Testing strategy
  - Verification steps

**PLAN.md Template:**
```markdown
# Implementation Plan: [Feature Name]

## Summary
[1-2 sentences]

## Prerequisites
- [Required services, dependencies]

## Implementation Steps

### 1. [Step Name]
- Files: `path/to/file.ts`
- Changes: [Description]

### 2. [Step Name]
...

## Testing Strategy
- Unit tests: [Approach]
- Integration: [Approach]
- E2E: [If applicable]

## Verification
- [ ] Build passes
- [ ] Tests pass
- [ ] Manual verification steps
```

### Phase 3: Implement

- Spawn `implementer` with plan file path
- Monitor for blockers/escalations
- Verify completion

**Spawn syntax:**
```
implementer "implement PLAN.md"
```

### Phase 4: Learn (Post-Completion)

- `continuous-learning` skill auto-invokes based on frontmatter triggers
- No explicit invocation needed
- New skills saved to `~/.agents/skills/learned/`

## Artifact Locations

| Artifact | Location |
|----------|----------|
| SPEC.md | Project root |
| RESEARCH.md | Project root |
| PLAN.md | Project root |

## Context Management

- Each subagent runs in fresh context
- Orchestrator stays lean - only manages handoffs
- Artifacts are the communication channel
- Don't pollute context with implementation details

## Execution Guidelines

1. **Check for existing artifacts first**
   - SPEC.md exists? → Skip Phase 0
   - RESEARCH.md exists? → Skip Phase 1
   - PLAN.md exists? → Skip Phase 2

2. **Keep orchestrator lean**
   - Don't do research yourself - spawn researchers
   - Don't implement - spawn implementer
   - Don't interview - spawn spec-interviewer

3. **Track progress with TodoWrite**
   - Break pipeline into phases
   - Mark each phase as in_progress/completed

## Error Handling

If any phase fails:
1. Document the failure in artifact
2. Assess if recoverable
3. If not recoverable, escalate to user with context

## Example Invocation

```
ace-orchestrator "Add user authentication with JWT tokens and refresh tokens"
```

Pipeline:
1. Spawn spec-interviewer → SPEC.md
2. Spawn researchers (parallel):
   - JWT best practices
   - Refresh token patterns
   - Existing auth in codebase
3. Merge research → RESEARCH.md
4. Plan implementation → PLAN.md
5. Spawn implementer → code + tests
