---
name: design-review
description: "UI validation for accessibility and visual consistency. Use proactively after building or modifying UI components, before commits with UI changes, or when reviewing PRs. Also use when users ask to review UI, check accessibility, audit design, validate component."
---

# Design Review

Validate UI for accessibility and visual consistency.

Source: https://rams.ai

Note: Web-focused but principles apply to other platforms.

## When to Use

- After building new UI components
- Before committing UI changes
- When reviewing PRs with UI changes
- To validate accessibility compliance

## What It Checks

### Accessibility (WCAG 2.1/2.2)

- Alt text for images
- Label associations for inputs
- Focus visibility
- Color contrast (4.5:1 normal, 3:1 large text)
- ARIA attributes
- Keyboard navigation
- Target size (min 24x24px for WCAG 2.2)

### Visual Consistency

- Layout alignment
- Spacing consistency
- Typography hierarchy
- Color token usage
- Border radius consistency

### State Coverage

- Default, hover, focus, active
- Disabled, error, loading, empty

## Manual Checklist

When reviewing UI components:

```
[ ] All interactive elements have focus states
[ ] Color alone doesn't convey meaning
[ ] Text contrast meets WCAG AA (4.5:1)
[ ] Buttons have min 24x24px target
[ ] Form inputs have associated labels
[ ] Images have alt text
[ ] Loading states use skeletons
[ ] Empty states have clear actions
[ ] Error messages near triggers
[ ] Animations respect prefers-reduced-motion
```

## Common Issues

| Issue | Fix |
|-------|-----|
| Missing alt text | Add descriptive alt |
| Low contrast | Use appropriate tokens |
| No focus visible | Add focus ring |
| Missing labels | Associate with inputs |
| Small targets | `min-h-6 min-w-6` |

## Integration

- Use `DESIGN_STYLE.md` for token values
- Use `ui-patterns` for build patterns
- Run this skill to validate the result
