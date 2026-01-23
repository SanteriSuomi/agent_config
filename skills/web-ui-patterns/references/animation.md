# Animation Reference

Motion performance rules for smooth, accessible animations.

---

## Rendering Pipeline

Understanding what triggers what:

| Stage | Properties | Cost |
|-------|------------|------|
| Composite | `transform`, `opacity` | Cheap (GPU) |
| Paint | `color`, `background`, `border` | Medium |
| Layout | `width`, `height`, `margin`, `padding`, `top`, `left` | Expensive |

**Rule**: Only animate composite properties for smooth motion.

---

## Never Patterns (critical)

These cause jank or crashes:

- **Never interleave layout reads and writes** — causes layout thrashing
- **Never animate layout continuously** — especially on large surfaces
- **Never drive animation from scroll events** — use Scroll Timeline API
- **Never `requestAnimationFrame` without stop condition** — memory leak
- **Never mix animation systems** — each measuring/mutating layout
- **Never `useEffect` for render-expressible logic** — extra renders
- **Never `will-change` outside active animation** — wastes GPU memory

## Mechanism Selection (critical)

```
Entrance/micro animation → CSS (tw-animate-css)
Interaction-driven → motion/react
Scroll-linked → Scroll Timeline API or IntersectionObserver
Layout change illusion → FLIP pattern
```

- Default to `transform` and `opacity`
- JS animation only when interaction requires it
- Paint/layout animation only on small, isolated surfaces
- One-shot effects acceptable more often than continuous

## FLIP Pattern (high)

For layout-like animations without layout cost:

```javascript
// First: record initial position
const first = element.getBoundingClientRect();

// Last: apply final state
element.classList.add('expanded');
const last = element.getBoundingClientRect();

// Invert: calculate delta, apply inverse transform
const deltaX = first.left - last.left;
const deltaY = first.top - last.top;
element.style.transform = `translate(${deltaX}px, ${deltaY}px)`;

// Play: animate to identity
requestAnimationFrame(() => {
  element.style.transition = 'transform 0.3s ease-out';
  element.style.transform = '';
});
```

## Measurement (high)

- Measure once, then animate via transform/opacity
- Batch all DOM reads before writes
- Never read layout repeatedly during animation

## Scroll (high)

- Prefer Scroll/View Timelines for scroll-linked motion
- Use `IntersectionObserver` for visibility and pausing
- Never poll scroll position
- Pause/stop animations when off-screen

## Paint (medium-high)

- Paint-triggering animation only on small elements
- Never animate paint-heavy properties on large containers
- Never animate CSS variables for transform/opacity/position
- Scope animated CSS variables locally

## Layers (medium)

- Compositor motion requires layer promotion
- Use `will-change` temporarily and surgically
- Avoid many or large promoted layers
- Remove `will-change` after animation completes

## Blur & Filters (medium)

- Keep blur animation small (<=8px)
- Blur only for short, one-time effects
- Never animate blur continuously
- Never animate blur on large surfaces
- Prefer opacity and translate before blur

## General Rules

- Only animate when explicitly requested
- Never `transition: all` — list properties explicitly
- Set correct `transform-origin`
- SVG: transforms on `<g>` wrapper with `transform-box: fill-box`
- Entrance: `ease-out`
- Interaction feedback: max 200ms
- Honor `prefers-reduced-motion`
- Animations interruptible — respond to user input mid-animation
- Pause loops when off-screen
- Never introduce custom easing unless requested
