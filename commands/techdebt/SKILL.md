# Tech Debt Cleanup

End-of-session cleanup. Reduces code bloat, removes duplication, applies modern idioms. Fully autonomous — detects project tooling and verifies changes.

$ARGUMENTS

---

## Workflow

### 1. Context Detection

Identify files to analyze (combine all sources):

```
1. Explicit args       → Use provided paths
2. Chat context        → Files modified this session
3. Git diff            → git diff --name-only HEAD
4. Git staged          → git diff --name-only --cached
```

If no context found, ask user or analyze entire `src/` directory.

### 2. Project Detection

Auto-detect verification commands before making changes:

```bash
# Check package.json scripts
cat package.json | jq '.scripts | keys'

# Common patterns:
# "test"      → pnpm run test (or npm/yarn)
# "lint"      → pnpm run lint
# "format"    → pnpm run format
# "check"     → pnpm run check
# "typecheck" → pnpm run typecheck
```

Detect config files:
- `biome.json` → `npx biome check --write`
- `.eslintrc*` → `npx eslint --fix`
- `tsconfig.json` → `npx tsc --noEmit`
- `vitest.config.*` / `jest.config.*` → test framework

Store detected commands for verification loop.

### 3. Analysis (Read-Only)

Read each target file. Look for:

**Code Reduction Opportunities:**

| Pattern | Before | After |
|---------|--------|-------|
| Optional chaining | `if (a && a.b && a.b.c)` | `a?.b?.c` |
| Nullish coalescing | `x !== null && x !== undefined ? x : d` | `x ?? d` |
| Destructuring | Multiple `obj.prop` | `const { prop } = obj` |
| Object shorthand | `{ name: name }` | `{ name }` |
| Array methods | For loop + push | `.map()/.filter()` |
| Inline single-use | Helper called once | Inline the code |
| Dead code | Unused exports, commented code | Delete |

**Code Smells:**
- Functions > 30 lines
- Nesting > 3 levels deep
- Duplicate code blocks (>10 lines)
- Single-use abstractions (inline them)
- Over-engineered patterns

### 4. Apply Changes

For each improvement:

```
1. Apply the fix (Edit tool)
2. Run verification:
   - Format: pnpm run format (if available)
   - Lint: pnpm run lint (if available)
   - Test: pnpm run test (if available)
3. If ALL pass → continue to next fix
4. If ANY fail → revert change, log reason, continue
```

**Risk Levels:**

| Risk | Examples | Action |
|------|----------|--------|
| Low | Formatting, unused imports, optional chaining | Apply immediately |
| Medium | Extract function, inline helper, rename | Apply, verify |
| High | Delete files, remove dependencies, API changes | Ask user first |

### 5. Report

Output summary when done:

```markdown
# Tech Debt Cleanup

## Summary
Analyzed X files, applied Y fixes, skipped Z items.

## Applied Changes
| File | Change | Lines |
|------|--------|-------|
| path/to/file.ts | Description | -N |

## Skipped
- `file.ts:42` — Reason (e.g., tests failed, needs review)

## Metrics
- Lines before: X
- Lines after: Y
- Net: -Z lines (N% reduction)
```

---

## Primary Goal: Reduce Code

> **More code begets more code. Entropy accumulates. Bias toward deletion.**

Three questions before every change:
1. What's the smallest codebase that solves this?
2. Does this change result in less total code?
3. What can we delete?

---

## Safe Refactoring (The Core 6)

These transformations are mechanically safe:

1. **Rename** — IDE/tooling handles all references
2. **Inline** — Compiler verifies equivalence
3. **Extract Method** — Reorganization, no logic change
4. **Introduce Local Variable** — Naming only
5. **Introduce Parameter** — Mechanical transformation
6. **Introduce Field** — Storage location change

---

## NEVER

- **Refactor without reading code first** — always Read before Edit
- **Add complexity** — every change should reduce, not increase
- **Create abstractions for <3 uses** — inline single/double-use code
- **Skip verification** — always run project's test/lint commands
- **Delete files without checking** — verify no dynamic imports first
- **Change public API signatures** — breaking changes need user approval
- **Guess at patterns** — understand codebase conventions first
- **Assume library idioms** — research best practices first

---

## Examples

### Optional Chaining

```typescript
// Before (verbose)
if (user && user.profile && user.profile.avatar) {
  return user.profile.avatar.url;
}

// After (concise)
return user?.profile?.avatar?.url;
```

### Inline Single-Use Helper

```typescript
// Before (unnecessary abstraction)
function formatDate(d: Date) {
  return d.toISOString().split('T')[0];
}
const date = formatDate(new Date()); // only call

// After (inlined)
const date = new Date().toISOString().split('T')[0];
```

### Remove Dead Code

```typescript
// Before
export function unusedHelper() { /* never imported anywhere */ }
export function usedFunction() { /* actually used */ }

// After
export function usedFunction() { /* actually used */ }
```

### Destructuring

```typescript
// Before
const name = config.name;
const port = config.port;
const host = config.host;

// After
const { name, port, host } = config;
```
