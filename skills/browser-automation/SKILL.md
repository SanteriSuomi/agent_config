---
name: browser-automation
description: 'Browser automation with persistent page state. Use proactively when relevant (e.g., testing web app features during development, verifying UI changes, E2E testing). Also use when users ask to navigate websites, fill forms, take screenshots, extract web data, or automate browser workflows. Triggers: "go to [url]", "open website", "visit", "click on", "fill form", "screenshot", "scrape", "test the website", "log into".'
allowed-tools: Bash(agent-browser:*)
source: https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md
last-synced: 2026-01-23
---

# Browser Automation with agent-browser

Run `agent-browser --help` for all available commands.

## Windows Git Bash Compatibility

**IMPORTANT:** The npm wrapper doesn't produce output in Git Bash. Use the direct executable:

```bash
# Define alias for convenience
alias ab='C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe'

# Or use full path directly
C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe open http://localhost:3000
```

The PowerShell wrapper (`agent-browser.ps1`) works correctly in PowerShell terminals.

## Sessions (REQUIRED)

**Always use uniquely named sessions** — one per task, feature, or test scenario:

```bash
# Name sessions by what you're testing
agent-browser --session cv-editor-test open http://localhost:3000/editor
agent-browser --session settings-page open http://localhost:3000/settings
agent-browser --session mobile-nav open http://localhost:3000
```

### Naming Convention

Use descriptive names based on context:
- `feature-login-flow` — testing login feature
- `bug-123-repro` — reproducing issue #123
- `e2e-checkout` — E2E checkout test
- `mobile-responsive` — mobile viewport testing

### Why Unique Sessions?
- **Avoid "Browser not launched" errors** — stale/reused sessions cause this
- **Clean state per task** — no leftover cookies, localStorage, or page state
- **Parallel testing** — run multiple browsers simultaneously
- **Isolation** — each task gets independent browser instance
- **Debuggability** — know which session belongs to which task

### Manage Sessions
```bash
agent-browser session list                    # Show active sessions
agent-browser --session feature-x close       # Close specific session
```

### Anti-pattern: Reusing session names
```bash
# BAD: Reusing generic names leads to stale state
agent-browser --session test open ...   # Used yesterday
agent-browser --session test open ...   # Today: "Browser not launched" error

# GOOD: Unique names per task
agent-browser --session test-jan24-cv open ...
```

## Quick start

```bash
# Use a unique session name for your task
agent-browser --session my-feature-test open <url>    # Navigate to page
agent-browser --session my-feature-test snapshot -i   # Get interactive elements with refs
agent-browser --session my-feature-test click @e1     # Click element by ref
agent-browser --session my-feature-test fill @e2 "text"  # Fill input by ref
agent-browser --session my-feature-test close         # Close browser
```

## Core workflow

1. **Create unique session**: Choose a descriptive name for your task
2. **Navigate**: `agent-browser --session <task-name> open <url>`
3. **Snapshot**: `agent-browser --session <task-name> snapshot -i` (returns refs like `@e1`, `@e2`)
4. **Interact** using refs from the snapshot
5. **Re-snapshot** after navigation or significant DOM changes
6. **Close**: `agent-browser --session <task-name> close`

## Limitations

- **Image reading is most likely not available** - rely on snapshots and text content rather than screenshots for page analysis. Use `snapshot -i` for interactive elements and `get text` for content extraction.

## Commands

### Navigation
```bash
agent-browser open <url>      # Navigate to URL
agent-browser back            # Go back
agent-browser forward         # Go forward
agent-browser reload          # Reload page
agent-browser close           # Close browser
```

### Snapshot (page analysis)
```bash
agent-browser snapshot            # Full accessibility tree
agent-browser snapshot -i         # Interactive elements only (recommended)
agent-browser snapshot -c         # Compact output
agent-browser snapshot -d 3       # Limit depth to 3
agent-browser snapshot -s "#main" # Scope to CSS selector
```

### Interactions (use @refs from snapshot)
```bash
agent-browser click @e1           # Click
agent-browser dblclick @e1        # Double-click
agent-browser focus @e1           # Focus element
agent-browser fill @e2 "text"     # Clear and type
agent-browser type @e2 "text"     # Type without clearing
agent-browser press Enter         # Press key
agent-browser press Control+a     # Key combination
agent-browser press ?             # Special chars: use char directly, not Shift+/
agent-browser keydown Shift       # Hold key down
agent-browser keyup Shift         # Release key
agent-browser hover @e1           # Hover
agent-browser check @e1           # Check checkbox
agent-browser uncheck @e1         # Uncheck checkbox
agent-browser select @e1 "value"  # Select dropdown
agent-browser scroll down 500     # Scroll page
agent-browser scrollintoview @e1  # Scroll element into view
agent-browser drag @e1 @e2        # Drag and drop
agent-browser upload @e1 file.pdf # Upload files
```

### Get information
```bash
agent-browser get text @e1        # Get element text
agent-browser get html @e1        # Get innerHTML
agent-browser get value @e1       # Get input value
agent-browser get attr @e1 href   # Get attribute
agent-browser get title           # Get page title
agent-browser get url             # Get current URL
agent-browser get count ".item"   # Count matching elements
agent-browser get box @e1         # Get bounding box
agent-browser get styles @e1      # Get computed styles
```

### Check state
```bash
agent-browser is visible @e1      # Check if visible
agent-browser is enabled @e1      # Check if enabled
agent-browser is checked @e1      # Check if checked
```

### Screenshots & PDF
```bash
agent-browser screenshot          # Screenshot to stdout
agent-browser screenshot path.png # Save to file
agent-browser screenshot --full   # Full page
agent-browser pdf output.pdf      # Save as PDF
```

### Video recording
```bash
agent-browser record start ./demo.webm    # Start recording (uses current URL + state)
agent-browser click @e1                   # Perform actions
agent-browser record stop                 # Stop and save video
agent-browser record restart ./take2.webm # Stop current + start new recording
```
Recording creates a fresh context but preserves cookies/storage from your session. If no URL is provided, it automatically returns to your current page. For smooth demos, explore first, then start recording.

### Wait
```bash
agent-browser wait @e1                     # Wait for element
agent-browser wait 2000                    # Wait milliseconds
agent-browser wait --text "Success"        # Wait for text
agent-browser wait --url "**/dashboard"    # Wait for URL pattern
agent-browser wait --load networkidle      # Wait for network idle
agent-browser wait --fn "window.ready"     # Wait for JS condition
```

### Mouse control
```bash
agent-browser mouse move 100 200      # Move mouse
agent-browser mouse down left         # Press button
agent-browser mouse up left           # Release button
agent-browser mouse wheel 100         # Scroll wheel
```

### Semantic locators (alternative to refs)
```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find first ".item" click
agent-browser find nth 2 "a" text
```

### Browser settings
```bash
agent-browser set viewport 1920 1080      # Set viewport size
agent-browser set device "iPhone 14"      # Emulate device
agent-browser set geo 37.7749 -122.4194   # Set geolocation
agent-browser set offline on              # Toggle offline mode
agent-browser set headers '{"X-Key":"v"}' # Extra HTTP headers
agent-browser set credentials user pass   # HTTP basic auth
agent-browser set media dark              # Emulate color scheme
```

### Cookies & Storage
```bash
agent-browser cookies                     # Get all cookies
agent-browser cookies set name value      # Set cookie
agent-browser cookies clear               # Clear cookies
agent-browser storage local               # Get all localStorage
agent-browser storage local key           # Get specific key
agent-browser storage local set k v       # Set value
agent-browser storage local clear         # Clear all
```

### Network
```bash
agent-browser network route <url>              # Intercept requests
agent-browser network route <url> --abort      # Block requests
agent-browser network route <url> --body '{}'  # Mock response
agent-browser network unroute [url]            # Remove routes
agent-browser network requests                 # View tracked requests
agent-browser network requests --filter api    # Filter requests
```

### Tabs & Windows
```bash
agent-browser tab                 # List tabs
agent-browser tab new [url]       # New tab
agent-browser tab 2               # Switch to tab
agent-browser tab close           # Close tab
agent-browser window new          # New window
```

### Frames
```bash
agent-browser frame "#iframe"     # Switch to iframe
agent-browser frame main          # Back to main frame
```

### Dialogs
```bash
agent-browser dialog accept [text]  # Accept dialog
agent-browser dialog dismiss        # Dismiss dialog
```

### JavaScript
```bash
agent-browser eval "document.title"   # Run JavaScript
```

## Managing Dev Servers with PM2

When testing local apps, use PM2 to manage the dev server in the background.

**Philosophy:** Start once, keep running. Most dev servers have watch/hot-reload built in (`npm run dev`, `vite`, `next dev`, etc.) — they auto-reload on file changes. Don't stop between tests. This applies to any long-running process with watch mode, not just web apps.

```bash
pm2 start "npm run dev" --name devserver   # Start (survives terminal close)
pm2 logs devserver                         # View logs
pm2 list                                   # Check status
pm2 delete devserver                       # Remove when done with project
```

---

## Example: Form submission

```bash
agent-browser --session form open https://example.com/form
agent-browser --session form snapshot -i
# Output shows: textbox "Email" [ref=e1], textbox "Password" [ref=e2], button "Submit" [ref=e3]

agent-browser --session form fill @e1 "user@example.com"
agent-browser --session form fill @e2 "password123"
agent-browser --session form click @e3
agent-browser --session form wait --load networkidle
agent-browser --session form snapshot -i  # Check result
agent-browser --session form close
```

## Example: Authentication with saved state

```bash
# Login once
agent-browser --session auth open https://app.example.com/login
agent-browser --session auth snapshot -i
agent-browser --session auth fill @e1 "username"
agent-browser --session auth fill @e2 "password"
agent-browser --session auth click @e3
agent-browser --session auth wait --url "**/dashboard"
agent-browser --session auth state save auth.json

# Later sessions: load saved state
agent-browser --session dashboard state load auth.json
agent-browser --session dashboard open https://app.example.com/dashboard
```

## Sessions (parallel browsers)

```bash
agent-browser --session test1 open site-a.com
agent-browser --session test2 open site-b.com
agent-browser session list
```

## JSON output (for parsing)

Add `--json` for machine-readable output:
```bash
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

## Debugging

```bash
agent-browser --session debug open example.com --headed   # Show browser window
agent-browser --session debug console                     # View console messages
agent-browser --session debug errors                      # View page errors
agent-browser --session debug network requests            # View network requests (v0.7+)
agent-browser --session debug storage local               # View localStorage (v0.7+)
agent-browser --session debug record start ./debug.webm   # Record from current page
agent-browser --session debug record stop                 # Save recording
agent-browser --session debug console --clear             # Clear console
agent-browser --session debug errors --clear              # Clear errors
agent-browser --session debug highlight @e1               # Highlight element
agent-browser --session debug trace start                 # Start recording trace
agent-browser --session debug trace stop trace.zip        # Stop and save trace
agent-browser --cdp 9222 snapshot                         # Connect via CDP
```

## Cloud Providers & Profiles

```bash
# Use cloud browser (Browserbase, Browser Use)
agent-browser -p browserbase open example.com
# Or set AGENT_BROWSER_PROVIDER=browserbase

# Persistent profiles (retain cookies, localStorage across restarts)
agent-browser --profile myprofile open example.com
```

## References

For detailed guides, load as needed:

- `~/.agents/skills/browser-automation/references/workarounds.md` — **Platform fixes, complex editors, Shadow DOM, iframes**
- `~/.agents/skills/browser-automation/references/authentication.md` — Auth patterns
- `~/.agents/skills/browser-automation/references/session-management.md` — Session lifecycle
- `~/.agents/skills/browser-automation/references/snapshot-refs.md` — Snapshot refs explained
- `~/.agents/skills/browser-automation/references/proxy-support.md` — Proxy configuration
- `~/.agents/skills/browser-automation/references/video-recording.md` — Recording details

## Troubleshooting

### "Browser not launched" Error

Use a fresh named session:
```bash
agent-browser --session fresh123 open http://example.com
```
This avoids stale default session state.

### Windows Git Bash: No Output

The npm wrapper (`agent-browser.cmd`) doesn't produce stdout in Git Bash. Solutions:

1. **Use direct executable** (recommended):
   ```bash
   C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe --session test open http://example.com
   ```

2. **Use PowerShell** instead of Git Bash - the `.ps1` wrapper works correctly.

### Windows: `/bin/sh.exe` not found

The npm-generated PowerShell wrapper tries to use `/bin/sh` which doesn't exist on Windows. Fix by editing `%APPDATA%\npm\agent-browser.ps1`:

```powershell
#!/usr/bin/env pwsh
$basedir=Split-Path $MyInvocation.MyCommand.Definition -Parent

$ret=0
if ($MyInvocation.ExpectingInput) {
  $input | & "$basedir/node_modules/agent-browser/bin/agent-browser-win32-x64.exe" $args
} else {
  & "$basedir/node_modules/agent-browser/bin/agent-browser-win32-x64.exe" $args
}
$ret=$LASTEXITCODE
exit $ret
```

### Complex Editors (Monaco, CodeMirror, etc.)

`fill @ref` doesn't work with virtual editors. See `references/workarounds.md` for JavaScript solutions.

### Element Not Found After Interaction

Refs change after DOM updates. Always re-snapshot:
```bash
agent-browser --session test click @e1
agent-browser --session test snapshot -i  # Get fresh refs
```

### "Daemon failed to start" Error (Windows)

The Rust CLI may fail to spawn the daemon process. Run the Node.js daemon manually:

```bash
# Clean any stale state files first
rm -f ~/.agent-browser/*.pid ~/.agent-browser/*.port ~/.agent-browser/*.stream

# Start daemon manually in a separate terminal (keep it running)
node C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/dist/daemon.js
```

Then use the CLI normally — it connects to the running daemon instead of spawning one.
