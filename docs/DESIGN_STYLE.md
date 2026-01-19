# Design System

> Flexoki Warm · Default global design tokens

Note: Web-focused but principles apply to other platforms.

## Philosophy

**Ink on paper.** Warm, quiet, functional. UI serves content, never competes.

### Principles

1. **Content-first** - UI serves content
2. **Anti-decorative** - No ornament without function
3. **Flat depth** - Borders and layering, never shadows
4. **Functional color** - Color communicates meaning, not mood

## Colors

### Base

| Token  | Hex       | Usage                   |
|--------|-----------|-------------------------|
| `bg`   | `#131210` | Page background         |
| `bg-2` | `#1C1B1A` | Cards, surfaces         |
| `ui`   | `#343331` | Borders, dividers       |
| `ui-2` | `#454340` | Hover borders           |
| `ui-3` | `#565451` | Active borders          |

### Text

| Token  | Hex       | Usage                   |
|--------|-----------|-------------------------|
| `tx`   | `#CECDC3` | Primary text, headings  |
| `tx-2` | `#878580` | Secondary text          |
| `tx-3` | `#6F6E69` | Muted, disabled         |

### Accent (Role-Based)

| Token               | Hex       | Usage                   |
|---------------------|-----------|-------------------------|
| `accent-text`       | `#D07A52` | Links, text             |
| `accent-fill`       | `#BE6843` | Button backgrounds      |
| `accent-fill-hover` | `#A85A3A` | Button hover            |
| `accent-stroke`     | `#D07A52` | Focus borders           |

### Semantic

| Token     | Hex       | Usage                   |
|-----------|-----------|-------------------------|
| `success` | `#879A39` | Success, active         |
| `warning` | `#D0A215` | Warnings, pending       |
| `danger`  | `#D14D41` | Errors, destructive     |

## Typography

| Role | Font            | Fallback          |
|------|-----------------|-------------------|
| Sans | Source Sans 3   | system-ui         |
| Mono | Monaspace Argon | SF Mono, monospace|

### Scale

| Size | Weight | Use                    |
|------|--------|------------------------|
| 11px | 400    | Labels, captions       |
| 12px | 400    | Small UI, metadata     |
| 14px | 400    | Body, inputs, buttons  |
| 16px | 600    | Section titles         |
| 20px | 600    | Page titles            |

**Never use 700/bold.** Differentiate with color.

## Spacing

4px base grid. All spacing is a multiple of 4.

| Token | Value | Use                |
|-------|-------|--------------------|
| `xs`  | 4px   | Inline gaps        |
| `sm`  | 8px   | Related elements   |
| `md`  | 16px  | Component padding  |
| `lg`  | 24px  | Section gaps       |
| `xl`  | 32px  | Page margins       |

## Border Radius

| Token | Value | Use              |
|-------|-------|------------------|
| `sm`  | 4px   | Checkboxes, tags |
| `md`  | 6px   | Buttons, inputs  |
| `lg`  | 8px   | Cards, modals    |

## Hard Constraints

- **No shadows** (`box-shadow`, `drop-shadow`)
- **No gradients**
- **Only defined color tokens**
- **Semantic colors for status only**
- **Focus states always visible**

## Components

### Buttons

| Variant   | Background    | Text      | Hover              |
|-----------|---------------|-----------|-------------------|
| Primary   | `accent-fill` | `#FFFCF0` | `accent-fill-hover`|
| Secondary | `ui`          | `tx`      | `ui-2`            |
| Ghost     | transparent   | `tx-2`    | `ui`              |
| Danger    | transparent   | `danger`  | `danger` bg 15%   |

### Inputs

- Background: `bg`
- Border: `1px solid ui-2`
- Focus: `1px solid accent-stroke`
- Placeholder: `tx-3`

### Cards

- Background: `bg-2`
- Border: `1px solid ui`
- Radius: `lg`

### Focus (Universal)

- `outline: 2px solid accent-stroke`
- `outline-offset: 2px`
- Always visible

## Transitions

- Properties: `background-color`, `border-color` only
- Duration: 150ms
- Easing: ease
- Never animate size, position, or layout

## CSS Tokens

```css
:root {
  --bg: #131210;
  --bg-2: #1C1B1A;
  --ui: #343331;
  --ui-2: #454340;
  --ui-3: #565451;
  --tx: #CECDC3;
  --tx-2: #878580;
  --tx-3: #6F6E69;
  --accent-text: #D07A52;
  --accent-fill: #BE6843;
  --accent-fill-hover: #A85A3A;
  --accent-stroke: #D07A52;
  --success: #879A39;
  --warning: #D0A215;
  --danger: #D14D41;
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --font-sans: 'Source Sans 3', system-ui, sans-serif;
  --font-mono: 'Monaspace Argon', 'SF Mono', monospace;
}
```
