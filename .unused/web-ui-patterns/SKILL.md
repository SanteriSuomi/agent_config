---
name: web-ui-patterns
description: "Web UI build patterns. AUTO-LOAD when: building/creating components, forms, buttons, modals, layouts; writing React/Next.js UI; adding animations; fixing accessibility. Triggers: 'add a button', 'create component', 'build form', 'make accessible', 'add animation', 'fix layout', 'how should I style', frontend, UI, a11y, WCAG."
sources:
  - https://github.com/ibelick/ui-skills
  - https://github.com/vercel-labs/web-interface-guidelines
merged-from:
  - baseline-ui, fixing-accessibility, fixing-motion-performance, fixing-metadata (ibelick/ui-skills)
  - web-design-guidelines (vercel-labs/web-interface-guidelines)
last-synced: 2026-01-23
---

# Web UI Patterns

Build patterns for accessible, performant web interfaces.

Conform to project's design style if one exists. After building, run `/design-review`.

---

## Before Building, Ask Yourself

1. **What's the primary user action?** — Design around it
2. **What states need handling?** — Default, loading, empty, error, success
3. **What can fail?** — Network, validation, permissions
4. **Who uses this?** — Keyboard users, screen readers, mobile, slow connections
5. **What's the URL story?** — Should state be deep-linkable?

---

## Decision Trees

### Choosing Interactive Elements

```
Need to trigger action? → <button>
Need to navigate? → <a> / <Link>
Need user input? → <input> / <select> / <textarea>
Need to toggle? → <button aria-pressed> or <input type="checkbox">
NEVER: <div onClick> or <span onClick>
```

### Choosing Animation Approach

```
Is it entrance/micro? → CSS (tw-animate-css)
Is it interaction-driven? → motion/react
Is it scroll-linked? → Scroll Timeline API or IntersectionObserver
Is it layout change? → FLIP pattern (measure → transform → animate)
NEVER: animate width/height/margin/padding directly
```

### Loading Reference Files

| Task | Load | Do NOT Load |
|------|------|-------------|
| Building accessible UI | `~/.agents/skills/web-ui-patterns/references/accessibility.md` | animation, metadata |
| Adding animations | `~/.agents/skills/web-ui-patterns/references/animation.md` | accessibility, metadata |
| Setting up meta/SEO | `~/.agents/skills/web-ui-patterns/references/metadata.md` | accessibility, animation |
| General UI work | Skim all as needed | — |

---

## Stack

- Tailwind CSS defaults (unless custom values exist)
- `motion/react` for JS animations
- `tw-animate-css` for entrance/micro animations
- `cn` utility (`clsx` + `tailwind-merge`)
- Accessible primitives: Base UI, React Aria, Radix

---

## Critical Rules (memorize these)

### Accessibility
- Every interactive control needs accessible name
- Icon-only buttons need `aria-label`
- Never `<div>`/`<span>` as buttons
- Modals trap focus; restore on close
- `prefers-reduced-motion` must be honored

### Animation
- Only `transform` + `opacity` (compositor-friendly)
- Never `transition: all`
- Never interleave layout reads/writes
- Never `will-change` outside active animation
- Never `useEffect` for render-expressible logic

### Forms
- Inputs need `<label>`, `autocomplete`, correct `type`
- Never block paste
- Errors inline next to fields
- Warn before navigation with unsaved changes

### Images
- Always `width` + `height` (prevents CLS)
- Below-fold: `loading="lazy"`
- Above-fold: `fetchpriority="high"`

### Layout
- `h-dvh` not `h-screen`
- Respect `safe-area-inset` for fixed elements
- Fixed z-index scale (no arbitrary values)

---

## Anti-patterns (with WHY)

| Anti-pattern | Why it's bad |
|--------------|--------------|
| `<div onClick>` | No keyboard access, no focus, not announced |
| `transition: all` | Animates unintended properties, performance hit |
| `outline-none` without replacement | Keyboard users can't see focus |
| `onPaste` + `preventDefault` | Blocks password managers, frustrates users |
| `user-scalable=no` | Accessibility violation, users can't zoom |
| Images without dimensions | Causes layout shift (poor CLS) |
| Large `.map()` without virtualization | Freezes UI, memory bloat |
| `will-change` always on | Wastes GPU memory, causes compositing issues |
| `useEffect` for derived state | Extra render, stale values, complexity |
| Interleaved reads/writes | Forces layout thrashing, janky animations |
| Hardcoded date/number formats | Breaks for non-US locales |

---

## Quick Reference

### Typography
- Headings: `text-balance` or `text-pretty`
- Data: `tabular-nums`
- Dense: `truncate` or `line-clamp`
- Use `…` not `...`, curly quotes not straight

### States to Handle
- Default, hover, focus, active
- Disabled, error, loading, empty
- Skeleton loaders for async content

### Touch
- `touch-action: manipulation`
- `overscroll-behavior: contain` in modals
- Min 24×24px touch targets

---

## References

For detailed rules, load as needed:

- `~/.agents/skills/web-ui-patterns/references/accessibility.md` — Full a11y rules, WCAG compliance
- `~/.agents/skills/web-ui-patterns/references/animation.md` — Motion performance, FLIP, scroll
- `~/.agents/skills/web-ui-patterns/references/metadata.md` — SEO, OG tags, structured data
