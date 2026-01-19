---
name: browser-automation
description: "Browser automation for debugging and testing using agent-browser CLI."
---

# Browser Automation

Browser automation for debugging, testing, and UI verification.

## Tool: agent-browser

CLI for browser automation. Install: `npm i -g agent-browser`

### Commands

```bash
# Open URL
agent-browser open https://localhost:3000

# Get accessibility snapshot (interactive elements + console)
agent-browser snapshot -i -c

# Click element by reference
agent-browser click @e2

# Fill input
agent-browser fill @e3 "text"

# Screenshot
agent-browser screenshot

# Get console logs
agent-browser console
```

### Element References

Snapshots return elements with refs like `@e1`, `@e2`. Use these refs for interactions:

```bash
$ agent-browser snapshot -i
@e1 [button] "Submit"
@e2 [textbox] "Email"
@e3 [link] "Sign up"

$ agent-browser click @e1
```

## Environment Detection

```
Project has web UI?
├── Yes → Start dev server, use agent-browser
│   ├── `agent-browser open <dev-url>`
│   ├── `agent-browser snapshot -i -c`
│   └── Interact and verify
│
└── No (CLI, library, backend-only)
    └── Skip browser testing, document limitation
```

## Common Workflows

### Debug UI Rendering

```bash
agent-browser open https://localhost:3000/page
agent-browser snapshot -i -c
# Review elements and console for errors
```

### Debug API Error

```bash
agent-browser open https://localhost:3000
# Trigger action in UI
agent-browser console
# Check for API errors
```

### Test User Flow

```bash
agent-browser open https://localhost:3000/login
agent-browser snapshot -i
agent-browser fill @e2 "user@example.com"
agent-browser fill @e3 "password"
agent-browser click @e1
agent-browser snapshot -i
# Verify result
```

## When to Use

- Verifying UI changes after implementation
- Debugging rendering issues
- Testing user flows
- Checking console errors

## When NOT to Use

- CLI-only applications
- Backend services without UI
- Unit tests (use testing frameworks)
- Simple static content (use WebFetch)
