# Accessibility Reference

Detailed accessibility rules for WCAG 2.1/2.2 compliance.

---

## Accessible Names (critical)

- Every interactive control needs an accessible name
- Icon-only buttons need `aria-label` or `aria-labelledby`
- Inputs must have associated `<label>` or `aria-label`
- Links need meaningful text (not "click here")
- Decorative icons use `aria-hidden="true"`

## Keyboard Access (critical)

- Never use `<div>`/`<span>` as buttons without keyboard support
- All interactive elements Tab-reachable
- Visible focus states required
- Never use `tabindex` > 0 (breaks natural order)
- Escape closes dialogs/modals

## Focus & Dialogs (critical)

- Modals trap focus inside
- Restore focus on dialog close
- Set initial focus in dialogs appropriately
- Prevent unexpected scroll jumps on focus

## Focus States

- Interactive elements need visible focus: `focus-visible:ring-*` or equivalent
- Never `outline-none` without focus replacement
- Use `:focus-visible` over `:focus` (avoid focus ring on click)
- Group focus with `:focus-within` for compound controls

## Semantics (high)

- Prefer native HTML elements over ARIA roles
- Required ARIA attributes when roles are used
- `<ul>`/`<ol>` with `<li>` for lists
- Maintain heading hierarchy (`<h1>`–`<h6>`)
- Use `<th>` for table headers
- Use semantic HTML (`<button>`, `<a>`, `<label>`, `<table>`) before ARIA

## Forms & Errors (high)

- Link errors to fields via `aria-describedby`
- Announce required fields
- Set `aria-invalid` on invalid inputs
- Associate helper text with inputs
- Explain why submit is disabled
- Inputs need `autocomplete` and meaningful `name`
- Use correct `type` (`email`, `tel`, `url`, `number`) and `inputmode`
- Never block paste (`onPaste` + `preventDefault`)
- Labels clickable (`htmlFor` or wrapping control)
- Disable spellcheck on emails, codes, usernames
- Submit button enabled until request starts; spinner during request
- Errors inline next to fields; focus first error on submit
- Placeholders end with `…` and show example pattern
- Warn before navigation with unsaved changes

## Announcements (medium-high)

- Use `aria-live` for critical errors/updates
- Use `aria-busy` for loading states
- Toasts shouldn't be sole notification method
- Use `aria-expanded`/`aria-controls` for toggles

## Contrast & States (medium)

- Sufficient text/icon contrast (4.5:1 normal, 3:1 large)
- Keyboard equivalents for hover interactions
- Disabled states indicated beyond color alone
- Never remove focus outlines without replacement

## Images

- Meaningful alt text for content images
- `alt=""` for decorative images
- `<img>` needs explicit `width` and `height` (prevents CLS)
- Below-fold images: `loading="lazy"`
- Above-fold critical images: `fetchpriority="high"`

## Touch & Interaction

- `touch-action: manipulation` (prevents double-tap zoom delay)
- `overscroll-behavior: contain` in modals/drawers/sheets
- Min 24×24px touch targets (WCAG 2.2)
- `autoFocus` sparingly—desktop only, single primary input
