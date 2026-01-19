---
name: browser-automation
description: "Browser automation with persistent page state. Use when users ask to navigate websites, fill forms, take screenshots, extract web data, test web apps, or automate browser workflows. Trigger phrases include \"go to [url]\", \"click on\", \"fill out the form\", \"take a screenshot\", \"scrape\", \"automate\", \"test the website\", \"log into\", or any browser interaction request."
source: https://github.com/vercel-labs/agent-browser
---

# Browser Automation (agent-browser)

Headless browser automation CLI for AI agents. Fast Rust CLI with Node.js fallback.

## Installation

```bash
npm install -g agent-browser && agent-browser install
```

## Core Workflow

1. **Navigate** → `agent-browser open <url>`
2. **Snapshot** → `agent-browser snapshot -i` (get refs like @e1, @e2)
3. **Interact** → `agent-browser click @e1` (use refs)
4. **Re-snapshot** → After page changes, snapshot again for new refs

**Always use refs (@e1, @e2) for deterministic element selection.**

## Quick Reference

### Navigation

| Command | Description |
|---------|-------------|
| `open <url>` | Navigate to URL |
| `back` | Go back |
| `forward` | Go forward |
| `reload` | Refresh page |
| `close` | Close browser |

### Snapshot (Get Element Refs)

```bash
agent-browser snapshot           # Full accessibility tree
agent-browser snapshot -i        # Interactive elements only (recommended)
agent-browser snapshot -i -c     # Interactive + compact
agent-browser snapshot -d 5      # Limit depth to 5
agent-browser snapshot -s "#main" # Scope to selector
```

**Output contains refs like `@e1`, `@e2` - use these for interactions.**

### Interactions

| Command | Description |
|---------|-------------|
| `click @e1` | Click element |
| `dblclick @e1` | Double-click |
| `fill @e1 "text"` | Clear and fill input |
| `type @e1 "text"` | Type into field (append) |
| `press Enter` | Press key |
| `hover @e1` | Hover over element |
| `select @e1 "value"` | Select dropdown option |
| `check @e1` | Check checkbox |
| `uncheck @e1` | Uncheck checkbox |
| `scroll down 500` | Scroll down 500px |
| `scrollintoview @e1` | Scroll element into view |
| `upload @e1 /path/to/file` | Upload file |
| `drag @e1 @e2` | Drag from e1 to e2 |

### Information Retrieval

| Command | Description |
|---------|-------------|
| `get text @e1` | Get text content |
| `get html @e1` | Get innerHTML |
| `get value @e1` | Get input value |
| `get attr @e1 href` | Get attribute |
| `get title` | Page title |
| `get url` | Current URL |
| `get count ".item"` | Count elements |
| `get box @e1` | Bounding box coordinates |

### State Checks

| Command | Description |
|---------|-------------|
| `is visible @e1` | Check visibility |
| `is enabled @e1` | Check if interactive |
| `is checked @e1` | Check checkbox state |

### Wait Conditions

```bash
agent-browser wait @e1              # Wait for element
agent-browser wait 2000             # Wait 2 seconds
agent-browser wait --text "Success" # Wait for text
agent-browser wait --url "**/done"  # Wait for URL pattern
agent-browser wait --load networkidle # Wait for network idle
```

### Screenshots & PDF

```bash
agent-browser screenshot           # Base64 output
agent-browser screenshot out.png   # Save to file
agent-browser screenshot --full    # Full page
agent-browser pdf document.pdf     # Save as PDF
```

### Semantic Locators (Alternative to Refs)

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find placeholder "Search" fill "query"
```

### Browser Configuration

```bash
agent-browser set viewport 1920 1080
agent-browser set device "iPhone 14"
agent-browser set media dark
agent-browser set offline on
agent-browser set headers '{"Authorization": "Bearer TOKEN"}'
```

### Cookies & Storage

```bash
agent-browser cookies                    # List cookies
agent-browser cookies set name value     # Set cookie
agent-browser cookies clear              # Clear all
agent-browser storage local              # List localStorage
agent-browser storage local set key val  # Set item
```

### Network Interception

```bash
agent-browser network route "*/api/*"              # Intercept
agent-browser network route "*/ads/*" --abort      # Block
agent-browser network route "*/data" --body '{"mock":true}'  # Mock
agent-browser network requests                     # View requests
agent-browser network requests --filter "api"      # Filter
```

### Tabs

```bash
agent-browser tab              # List tabs
agent-browser tab new          # New tab
agent-browser tab new <url>    # New tab with URL
agent-browser tab 2            # Switch to tab 2
agent-browser tab close        # Close current tab
```

### Frames

```bash
agent-browser frame "#iframe"  # Switch to iframe
agent-browser frame main       # Return to main
```

### Dialogs

```bash
agent-browser dialog accept           # Accept alert/confirm
agent-browser dialog accept "answer"  # Accept prompt with text
agent-browser dialog dismiss          # Dismiss
```

### Sessions (Isolated Instances)

```bash
agent-browser --session user1 open example.com
agent-browser --session user2 open example.com
agent-browser session list
```

### State Persistence

```bash
agent-browser state save auth.json   # Save cookies/storage
agent-browser state load auth.json   # Restore session
```

### Debugging

```bash
agent-browser console            # View console messages
agent-browser errors             # View errors
agent-browser highlight @e1      # Highlight element
agent-browser eval "document.title"  # Run JavaScript
agent-browser --headed open url  # Show browser window
agent-browser --debug open url   # Verbose output
```

### JSON Output (for Parsing)

```bash
agent-browser snapshot --json
agent-browser get text @e1 --json
```

## Example Workflows

### Login Flow

```bash
agent-browser open "https://example.com/login"
agent-browser snapshot -i
# Output shows @e1=email, @e2=password, @e3=submit
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json  # Save for reuse
```

### Form Submission

```bash
agent-browser open "https://example.com/form"
agent-browser snapshot -i
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser select @e3 "Option 2"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --text "Thank you"
agent-browser screenshot confirmation.png
```

### Data Extraction

```bash
agent-browser open "https://example.com/products"
agent-browser snapshot -i
agent-browser get text @e1 --json  # Product name
agent-browser get text @e2 --json  # Price
agent-browser get attr @e3 href    # Link
```

### Multi-Tab Workflow

```bash
agent-browser open "https://site-a.com"
agent-browser tab new "https://site-b.com"
agent-browser tab 1    # Switch to first tab
agent-browser get text @e1
agent-browser tab 2    # Switch to second tab
agent-browser get text @e1
```

## Best Practices

1. **Always snapshot before interacting** - refs change on page updates
2. **Use `-i` flag** for snapshot to get only interactive elements
3. **Use refs (@e1) over CSS selectors** - more reliable for AI
4. **Re-snapshot after navigation** - page changes invalidate refs
5. **Use `--json` for parsing** - structured output for automation
6. **Save auth state** - reuse `state save/load` for authenticated sessions
7. **Wait appropriately** - use `wait` commands to handle async content

## Error Handling

If an element ref is invalid:
1. Re-run `snapshot -i` to get fresh refs
2. Verify element exists with `is visible @eX`
3. Use `wait @eX` if element loads asynchronously

## Platform Notes

- Native Rust binary: macOS (ARM64/x64), Linux (ARM64/x64), Windows (x64)
- Falls back to Node.js on unsupported platforms
- Requires Chromium (installed via `agent-browser install`)
