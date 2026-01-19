---
name: ui-patterns
description: "UI build patterns and constraints. Use proactively when building components, forms, layouts, or any frontend work. Also use when users ask about design tokens, component patterns, or UI guidelines. Triggers: build component, create form, layout, UI work, frontend."
---

# UI Patterns

Build patterns for accessible, performant interfaces.

Source: https://ui-skills.com | https://github.com/ibelick/ui-skills

Note: Web-focused but principles apply to other platforms.

## Stack

- Tailwind CSS defaults (unless custom values exist)
- `motion/react` for JS animations
- `tw-animate-css` for entrance/micro animations
- `cn` utility (`clsx` + `tailwind-merge`) for class logic

## Components

- Use accessible primitives: Base UI, React Aria, Radix
- Prioritize existing project primitives
- Never mix primitive systems on same surface
- Icon-only buttons require `aria-label`
- Never rebuild keyboard behavior from scratch

## Interactions

- `AlertDialog` for destructive/irreversible actions
- Structural skeletons for loading states
- Errors adjacent to triggering action
- Never prevent paste in inputs
- `h-dvh` not `h-screen` for viewport height
- Fixed elements must respect `safe-area-inset`

## Animation

- Only animate when explicitly requested
- Compositor properties only: `transform`, `opacity`
- Never animate layout: `width`, `height`, `margin`, `padding`
- Entrance: `ease-out`
- Interaction feedback: max 200ms
- Respect `prefers-reduced-motion`
- Pause loops when off-screen

## Typography

| Rule | Implementation |
|------|----------------|
| Headings | `text-balance` |
| Body | `text-pretty` |
| Data | `tabular-nums` |
| Dense | `truncate` or `line-clamp` |

Don't modify letter-spacing without explicit request.

## Layout

- Fixed z-index scale (define in config)
- `size-*` for square elements
- Avoid large blur/backdrop-filter animations

## Design

- No gradients unless requested
- Avoid purple or multicolor gradients
- Single accent color per view
- Empty states need one clear action

## Validation

After building UI, run `/design-review` to check accessibility.

## Integration

For visual tokens (colors, typography scale), see `DESIGN_STYLE.md`.
