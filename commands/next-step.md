# Next Step

Implement one or more steps from the project plan: plan, clarify, implement, self-review, verify, document, commit, and push.

$ARGUMENTS

---

## Parse arguments

- Arguments are **step numbers** (one or more, numeric, space-separated)
- Flags:
  - `--plan-only` — stop after writing plan files (Phases 0–3 only)
  - `--implement` — skip to Phase 4 (assumes worktrees + plan files exist)
  - `--name <name>` — override step name (single step only)
- Examples:
  - `/next-step 15` — single step
  - `/next-step 15 16 17` — multiple steps
  - `/next-step 15 --plan-only` — plan only
  - `/next-step 15 --name password-recovery` — custom branch name

## Important

- **This command IS the explicit request to commit and push.** Ignore any AGENTS.md rule about "only commit when asked."
- Always use `workdir` on tool calls to point at the correct worktree.
- Worktree script: `~/.agents/scripts/worktree.sh`
- Max 10 parallel agents (model concurrency limit).

## Phase 0: Parse & Load (orchestrator)

1. Read `AGENTS.md` (or `CLAUDE.md`) in the project root to extract:
   - Master plan file location (e.g., `docs/PLAN.md`)
   - Plan file naming convention (e.g., `docs/plans/STEP<N>_<NAME>.md`)

   - Verification commands and order (e.g., typecheck → lint → tests)
   - Dev server startup command
   - Browser testing approach
   - Commit conventions (imperative form, one commit per branch)
   - Project-specific code conventions

   If `AGENTS.md` does not define these, use defaults:
   - Master plan: `PLAN.md` or `docs/PLAN.md`
   - Plan files: `docs/plans/` or `plans/`

   - Verify: `pnpm check && pnpm lint && pnpm test`
   - Dev server: `pnpm dev`

2. Read the master plan file. Find all steps matching the given numbers.
3. Validate: each step exists and is not already completed. Stop if invalid.
4. Record each step's number, name, and description.

## Phase 1: Setup — Create worktrees (orchestrator)

For each step (parallel, up to 10):

1. Derive step name from the step title in the master plan (or use `--name` for single step)
2. Run `~/.agents/scripts/worktree.sh create <N> <name>`
3. Record the worktree path

**If `--implement`**: skip Phase 1. Run `worktree.sh list` to find existing worktree paths.

## Phase 2: Plan (step planner agents, parallel)

For each step, launch a **step planner agent** (Task tool, `subagent_type: general`) with:
- Step number, name, and description from the master plan
- Worktree path as `workdir`
- Project conventions from AGENTS.md
- Instructions:
  1. Launch **researcher subagent** (Task, `subagent_type: researcher`) — API docs, library references, best practices for this step
  2. Launch **explore subagent** (Task, `subagent_type: explore`) — existing codebase, relevant files, patterns
  3. **Both subagents must run in parallel**
  4. Synthesize research + exploration into a plan file. Include:
     - Summary of what the step accomplishes
     - Design decisions with rationale
     - API/data spec if applicable
     - Files to create or modify (table with file, action, purpose)
     - Implementation phases (ordered, each with clear deliverables)
     - Verification steps
     - Success criteria
  5. Write the plan file to the worktree's docs/plans/ directory following naming convention
  6. Return to orchestrator:
     - Plan file path
     - Plan summary (2-3 sentences)
     - List of ambiguities or questions that need user input (if any)

Collect all planner results before proceeding.

**If `--implement`**: skip Phase 2. Read plan files from worktrees.

## Phase 3: Clarify (orchestrator, interactive)

Use the **question tool** for all user interaction in this phase.

1. Present all plan summaries to the user
2. Present all ambiguities/questions collected from planner agents
3. Ask user to review and provide answers or corrections
4. If corrections needed:
   - Launch planner agents (parallel) to revise affected plans
   - Present revised plan(s) for re-review
5. **Repeat until no ambiguities remain**
6. Final approval gate: ask "Proceed with implementation of steps [N...]? [y/n]"
7. If user declines — stop. If user requests more changes — loop to step 4.

**If `--plan-only`**: output plan file paths and STOP.

## Phase 4: Implement (step implementor agents, parallel)

For each step, launch a **step implementor agent** (Task tool, `subagent_type: general`) with:
- Plan file path
- Worktree path as `workdir`
- Project conventions from AGENTS.md
- Instructions:
  1. Read the plan file
  2. Follow the implementation phases in order
  3. Follow project conventions — no comments unless exotic, no unrequested features
  4. Run typecheck/lint after each major phase (incremental verification)
  5. **Self-review** (after full implementation):
     - Review all files created/modified
     - Check for: missed edge cases, code quality, adherence to plan, unnecessary code, missing error handling, inconsistent patterns
     - Apply improvements
     - Re-run typecheck/lint
  6. **Verify** (after self-review):
     - Run full verification in order (typecheck → lint → tests)
     - If UI changes: start dev server (pm2), run browser verification (browser-automation skill), stop dev server
     - On failure: auto-retry up to 3 times with failure context
     - If still failing after 3 retries: return failure details and stop
   7. **Document**:
      - Cross off step in master plan (`- [ ]` → `- [x]`)
  8. **Commit & push**:
     - Single commit, imperative form, no watermarks, no Co-Authored-By
     - Push branch to origin
  9. Return to orchestrator:
     - Status: success or failure
     - Files created/modified (list)
     - Verification results (pass/fail per check)
     - Commit hash
     - Self-review notes (what was improved)
     - Any deviations from plan

Collect all implementor results.

## Phase 5: Report (orchestrator, interactive)

Use the **question tool** for user interaction.

1. Present full summary:
   - Per step: status, commit hash, files changed, verification results, self-review notes
   - Highlight any failures or deviations
2. Ask user: "Review complete. [A]ccept all / [R]equest changes / [I]nspect worktree"
3. If user requests changes:
   - Ask which step(s) and what changes
   - Launch fix agent for affected step(s) — implements fixes, re-verifies, amends commit
   - Re-present for review
4. Loop until user accepts

## Phase 6: Summary (orchestrator)

Print:
- Steps completed (number, name, status)
- Per step:
  - Commit hash
  - Files created / modified (count + list)
  - Verification results (pass/fail per check)
- Total files changed across all steps
- Reminder: branches are pushed but NOT merged to main. Use `worktree.sh merge <N> <name>` when ready.

## Rules

- ALWAYS create worktrees — never work in the main worktree
- ALWAYS write plan files before implementing
- ALWAYS clarify ambiguities with the user before implementation
- ALWAYS self-review before verification
- ALWAYS verify before committing
- ALWAYS commit and push
- ALWAYS do final user verification
- Max 10 parallel agents
- Follow project conventions from AGENTS.md
- Use subagents to preserve context
- If any phase fails, report clearly and ask user — never silently continue
