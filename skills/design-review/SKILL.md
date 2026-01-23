---
name: design-review
description: "UI validation for accessibility and visual consistency. AUTO-LOAD after building UI, before commits touching UI, when reviewing PRs. Triggers: 'review this component', 'check accessibility', 'is this accessible', 'audit UI', WCAG, validate, design review."
sources:
  - https://rams.ai
  - https://github.com/vercel-labs/web-interface-guidelines
last-synced: 2026-01-23
metadata:
  argument-hint: <file-or-pattern>
---

# Design Review

Validate UI code for accessibility and visual consistency.

Use `web-ui-patterns` while building. Use this skill to validate the result.

---

## Before Reviewing, Ask

1. **Who uses this?** — Keyboard users? Screen readers? Mobile?
2. **What states exist?** — Loading, empty, error, disabled?
3. **What can break?** — Missing labels? No focus? Bad contrast?
4. **Is it consistent?** — Matches project's design tokens?

---

## How to Review

1. Read the specified files
2. Check against rules below
3. Output findings in `file:line` format

### Output Format

Group by file. Terse — state issue + location.

```text
## src/Button.tsx

src/Button.tsx:42 - icon button missing aria-label (screen readers can't announce)
src/Button.tsx:18 - input lacks label (form not accessible)
src/Button.tsx:55 - animation missing prefers-reduced-motion (motion sensitivity)

## src/Modal.tsx

src/Modal.tsx:12 - missing overscroll-behavior: contain (scroll bleeds to body)

## src/Card.tsx

✓ pass
```

---

## Accessibility (WCAG 2.1/2.2)

| Check | Why |
|-------|-----|
| Icon-only buttons have `aria-label` | Screen readers need text |
| Form controls have `<label>` | Clickable, announced |
| Interactive elements keyboard-accessible | Not everyone uses mouse |
| `<button>` for actions, `<a>` for navigation | Semantics matter for AT |
| Images have `alt` (or `alt=""` if decorative) | Screen readers describe |
| Decorative icons have `aria-hidden="true"` | Don't announce noise |
| Headings hierarchical `<h1>`–`<h6>` | Navigation structure |
| Color contrast 4.5:1 (normal) / 3:1 (large) | Low vision users |
| Touch targets min 24×24px | WCAG 2.2 requirement |

## Focus States

| Check | Why |
|-------|-----|
| Interactive elements have visible focus | Keyboard users need to see where they are |
| No `outline-none` without replacement | Removes all focus indication |
| Uses `:focus-visible` over `:focus` | Avoids focus ring on mouse click |

## Forms

| Check | Why |
|-------|-----|
| Inputs have `autocomplete` and `name` | Browser autofill, form submission |
| Correct `type` and `inputmode` | Right keyboard on mobile |
| No paste blocking | Breaks password managers |
| Labels clickable via `htmlFor` | Larger hit target |
| Errors inline next to fields | Easy to find and fix |

## Animation

| Check | Why |
|-------|-----|
| Honors `prefers-reduced-motion` | Motion sensitivity, vestibular disorders |
| Only `transform`/`opacity` animated | Performance (compositor-only) |
| No `transition: all` | Animates unintended properties |

## Images

| Check | Why |
|-------|-----|
| Explicit `width` and `height` | Prevents layout shift (CLS) |
| Below-fold: `loading="lazy"` | Performance |
| Above-fold: `fetchpriority="high"` | LCP optimization |

## Performance

| Check | Why |
|-------|-----|
| Large lists (>50) virtualized | Prevents UI freeze |
| No layout reads in render | Causes jank |

## Visual Consistency

Check against project's design style:
- Color token usage (no hardcoded colors)
- Spacing consistency (uses scale)
- Border radius consistency
- Typography hierarchy

## State Coverage

Verify all states exist:
- Default, hover, focus, active
- Disabled, error, loading, empty

---

## Anti-patterns (with WHY)

| Anti-pattern | Why it's bad |
|--------------|--------------|
| `user-scalable=no` | Prevents zooming — accessibility violation |
| `onPaste` + `preventDefault` | Breaks password managers, frustrates users |
| `transition: all` | Performance hit, animates unintended props |
| `outline-none` alone | Keyboard users can't see focus |
| `<div>`/`<span>` with click handlers | No keyboard, no announce, no semantics |
| Images without dimensions | Layout shift hurts UX and Core Web Vitals |
| Large `.map()` without virtualization | Freezes UI, memory issues |
| Form inputs without labels | Not accessible, not clickable |
| Icon buttons without `aria-label` | Silent to screen readers |
| Hardcoded date/number formats | Breaks for international users |
| `autoFocus` everywhere | Confusing on mobile, unexpected scroll |

---

## Quick Checklist

```
[ ] All interactive elements have focus states
[ ] Color alone doesn't convey meaning
[ ] Text contrast meets WCAG AA (4.5:1)
[ ] Touch targets min 24×24px
[ ] Form inputs have associated labels
[ ] Images have alt text
[ ] Loading states use skeletons
[ ] Empty states have clear actions
[ ] Error messages near triggers
[ ] Animations respect prefers-reduced-motion
```
