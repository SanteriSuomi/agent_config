---
name: tui-design-style
description: "Terminal UI design system. Use for ALL TUI work. Dark mode, Flexoki-inspired palette mapped to terminal colors. Auto-triggers: TUI, terminal UI, CLI, ratatui, bubbletea, textual, ink, blessed."
---

> **MANDATORY: Use this design system for all TUI work. Consistent with web-design-style philosophy.**

## Before Styling, Ask

1. **Which color profile?** → ANSI 16, 256, or true color
2. **Which semantic category?** → bg, text, accent, or semantic
3. **Which state?** → default, focused, selected, disabled

## Component Selection

```
User's primary action     → Primary (accent bg, reversed)
Secondary/cancel action   → Secondary (ui border)
Destructive action        → Danger (danger color)
Low-emphasis/tertiary     → Ghost (no border)
```

# TUI Design System

> Flexoki-inspired · Dark mode · Content-first terminal aesthetic

## Philosophy

Same as web: **Ink on paper.** Warm, quiet, functional.

1. **Content-first** — UI serves content
2. **Anti-decorative** — No ornament without function
3. **Flat depth** — Borders only, no shadows (n/a anyway)
4. **Functional color** — Color communicates meaning, not mood

## Color Profiles

Support graceful degradation across terminal capabilities:

| Profile | Detection | Fallback |
|---------|-----------|----------|
| True Color (24-bit) | `$COLORTERM=truecolor` | Use exact hex |
| 256 Color | Default modern | Map to nearest |
| ANSI 16 | Legacy/accessible | Use base 16 |

## Colors

### Base (True Color / Hex)

| Token | Hex | 256 | ANSI 16 | Usage |
|-------|-----|-----|---------|-------|
| `bg` | `#131210` | 233 | Black (0) | App background |
| `bg-2` | `#1C1B1A` | 234 | Black (0) | Panels, surfaces |
| `ui` | `#343331` | 236 | DarkGray (8) | Borders, dividers |
| `ui-2` | `#454340` | 238 | DarkGray (8) | Hover borders |
| `ui-3` | `#565451` | 240 | Gray (7) | Active borders |

### Text

| Token | Hex | 256 | ANSI 16 | Usage |
|-------|-----|-----|---------|-------|
| `tx` | `#CECDC3` | 251 | White (15) | Primary text |
| `tx-2` | `#878580` | 245 | Gray (7) | Secondary text |
| `tx-3` | `#6F6E69` | 242 | DarkGray (8) | Disabled only |

### Accent (Flexoki Orange)

| Token | Hex | 256 | ANSI 16 | Usage |
|-------|-----|-----|---------|-------|
| `accent` | `#D07A52` | 173 | Yellow (3) | Links, highlights |
| `accent-bright` | `#BE6843` | 167 | Red (1) | Focused elements |

### Semantic

| Token | Hex | 256 | ANSI 16 | Usage |
|-------|-----|-----|---------|-------|
| `success` | `#879A39` | 106 | Green (2) | Success, active |
| `warning` | `#D0A215` | 178 | Yellow (3) | Warnings, pending |
| `danger` | `#D14D41` | 167 | Red (1) | Errors, destructive |
| `info` | `#4385BE` | 67 | Cyan (6) | Information |

## Typography

### Text Emphasis

| Style | ANSI Code | Use |
|-------|-----------|-----|
| **Bold** | `ESC[1m` | Headings, focused items |
| *Dim* | `ESC[2m` | Disabled, secondary |
| _Underline_ | `ESC[4m` | Links (sparingly) |
| Reverse | `ESC[7m` | Selection, focus |

**Avoid:** Italic (poor support), Blink (annoying), Strikethrough (unclear)

### Nerd Font Icons (Optional)

```
Files:    (folder)   (file)   (git)
Status:   (success)  (error)  (warning)
Actions:  (edit)    (search) (settings)
```

Fallback to ASCII when Nerd Fonts unavailable.

## Borders

### Box Drawing Characters

| Style | Use | Characters |
|-------|-----|------------|
| Light | Default borders | `┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼` |
| Heavy | Focused panels | `┏ ┓ ┗ ┛ ━ ┃ ┣ ┫ ┳ ┻ ╋` |
| Rounded | Softer aesthetic | `╭ ╮ ╰ ╯ ─ │` |
| Double | Modals, emphasis | `╔ ╗ ╚ ╝ ═ ║ ╠ ╣ ╦ ╩ ╬` |
| ASCII | Maximum compat | `+ - | ` |

### Border Selection

```
Default panel     → Light (─ │)
Focused panel     → Heavy (━ ┃) or accent color
Modal/dialog      → Double (═ ║) or rounded (╭ ╮)
ASCII fallback    → + - |
```

## Spacing

Character-based grid. All spacing in whole characters.

| Token | Value | Use |
|-------|-------|-----|
| `xs` | 1 char | Inline gaps |
| `sm` | 2 chars | Related elements |
| `md` | 4 chars | Component padding |
| `lg` | 6 chars | Section gaps |

## Components

### Buttons

```
Primary (focused):   [▓▓Submit▓▓]     # reversed
Primary:             [ Submit ]        # accent border
Secondary:           [ Cancel ]        # ui border
Ghost:                 Cancel          # no border
Danger:              [ Delete ]        # danger color
Disabled:            [ Submit ]        # dim text
```

### Inputs

```
Default:    Username: [              ]
With value: Username: [john_doe      ]
Focused:    ┏━ Username ━━━━━━━━━━━━━┓
            ┃ john_doe█              ┃
            ┗━━━━━━━━━━━━━━━━━━━━━━━━┛
Placeholder: Search: [Type to search...] (dim)
```

### Lists

```
  Item 1
▶ Item 2      # selected: symbol + highlight/reverse
  Item 3
  Item 4
```

Multi-select:
```
[x] Option 1
[ ] Option 2
[x] Option 3
```

### Tables

```
┌─────────────┬──────────┬─────────┐
│ Name        │ Status   │ Actions │  # header: bold
├─────────────┼──────────┼─────────┤
│ Project A   │ Active   │ Edit    │
│ Project B   │ Pending  │ Edit    │  # selected: reverse
│ Project C   │ Done     │ Edit    │
└─────────────┴──────────┴─────────┘
```

### Progress

```
Determinate:   [████████████░░░░░░░░] 60%
Indeterminate: Loading ⠋  (braille spinner)
```

Spinner sets:
- Braille: `⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏`
- Classic: `| / - \`
- Dots: `⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷`

### Modals

```
╔═══════ Confirm ═══════════════════╗
║                                   ║
║  Are you sure you want to delete? ║
║                                   ║
║        [ Yes ]    [ No ]          ║
║                                   ║
╚═══════════════════════════════════╝
```

Center on screen. Clear area behind before rendering.

### Status Bar

```
┌─────────────────────────────────────────┐
│ ...content...                           │
├─────────────────────────────────────────┤
│ INSERT │ Ln 42, Col 8 │ UTF-8 │ 2 Errors│
└─────────────────────────────────────────┘
```

## Focus States

| Method | When |
|--------|------|
| Reverse video | Primary selection |
| Heavy border | Focused panel/widget |
| Accent color | Focused interactive element |
| Prefix symbol | List items (`▶`, `>`, `→`) |

**Always visible.** Never rely on color alone.

## Hard Constraints

- **Only defined color tokens**
- **Semantic colors for status only**
- **Focus states always visible**
- **Degrade gracefully** (true color → 256 → 16 → mono)
- **Prefer reverse video** over color for selection

## Framework Examples

### Ratatui (Rust)

```rust
let style = Style::default()
    .fg(Color::Rgb(206, 205, 195))  // tx
    .bg(Color::Rgb(19, 18, 16));    // bg

let focused = Style::default()
    .fg(Color::Rgb(208, 122, 82))   // accent
    .add_modifier(Modifier::BOLD);

let selected = Style::default()
    .add_modifier(Modifier::REVERSED);
```

### Lipgloss (Go/Bubbletea)

```go
var style = lipgloss.NewStyle().
    Foreground(lipgloss.Color("#CECDC3")).
    Background(lipgloss.Color("#131210")).
    Padding(0, 1).
    Border(lipgloss.RoundedBorder()).
    BorderForeground(lipgloss.Color("#343331"))

// Adaptive for light/dark terminals
lipgloss.AdaptiveColor{Light: "#1C1B1A", Dark: "#CECDC3"}
```

### Textual (Python)

```python
# In CSS file
Screen {
    background: #131210;
}

.panel {
    background: #1C1B1A;
    border: solid #343331;
}

.panel:focus {
    border: solid #D07A52;
}

Button {
    background: #343331;
    color: #CECDC3;
}

Button:hover {
    background: #454340;
}
```

## Accessibility

- **Use ANSI 16 for max accessibility** — users control their terminal theme
- **Don't convey info by color alone** — use symbols, text, position
- **Provide config to disable animations** — respect reduced motion
- **Support vim keys** (`h/j/k/l`) alongside arrows
- **Consistent shortcuts** — Tab for focus, Enter for activate, Esc for cancel
