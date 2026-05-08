---
name: browser-automation
description: "Browser automation with persistent page state. Use proactively when relevant (e.g., testing web app features during development, verifying UI changes, E2E testing). Also use when users ask to navigate websites, fill forms, take screenshots, extract web data, or automate browser workflows. Triggers: go to [url], open website, visit, click on, fill form, screenshot, scrape, test the website, log into."
allowed-tools: Bash(npx agent-browser:*), Bash(agent-browser:*)
license: MIT
compatibility: opencode
metadata:
  source: https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md
  last-synced: "2026-04-30"
---

# Browser Automation with agent-browser

The CLI uses Chrome/Chromium via CDP directly. Written in Rust (since v0.20.0). Install via `npm i -g agent-browser`, `brew install agent-browser`, or `cargo install agent-browser`. Run `agent-browser install` to download Chrome. Existing Chrome, Brave, Playwright, and Puppeteer installations are detected automatically. Run `agent-browser upgrade` to update to the latest version.

## Core Workflow

Every browser automation follows this pattern:

1. **Navigate**: `agent-browser open <url>`
2. **Snapshot**: `agent-browser snapshot -i` (get element refs like `@e1`, `@e2`)
3. **Interact**: Use refs to click, fill, select
4. **Re-snapshot**: After navigation or DOM changes, get fresh refs

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait 2000
agent-browser snapshot -i  # Check result
```

## Command Chaining

Commands can be chained with `&&` in a single shell invocation. The browser persists between commands via a background daemon, so chaining is safe and more efficient than separate calls.

```bash
# Chain open + snapshot in one call (open already waits for page load)
agent-browser open https://example.com && agent-browser snapshot -i

# Chain multiple interactions
agent-browser fill @e1 "user@example.com" && agent-browser fill @e2 "password123" && agent-browser click @e3

# Navigate and capture
agent-browser open https://example.com && agent-browser screenshot
```

**When to chain:** Use `&&` when you don't need to read the output of an intermediate command before proceeding (e.g., open + wait + screenshot). Run commands separately when you need to parse the output first (e.g., snapshot to discover refs, then interact using those refs).

## Batch Execution

ALWAYS use `batch` when running 2+ commands in sequence. Batch executes commands in order, so dependent commands (like navigate then screenshot) work correctly. Each quoted argument is a separate command.

```bash
# Navigate and take a snapshot
agent-browser batch "open https://example.com" "snapshot -i"

# Navigate, snapshot, and screenshot in one call
agent-browser batch "open https://example.com" "snapshot -i" "screenshot"

# Click, wait, then screenshot
agent-browser batch "click @e1" "wait 1000" "screenshot"

# With --bail to stop on first error
agent-browser batch --bail "open https://example.com" "click @e1" "screenshot"
```

Only use a single command (not batch) when you need to read the output before deciding the next command. For example, you must run `snapshot -i` as a single command when you need to read the refs to decide what to click. After reading the snapshot, batch the remaining steps.

Stdin mode is also supported for programmatic use:

```bash
echo '[["open","https://example.com"],["screenshot"]]' | agent-browser batch --json
agent-browser batch --bail < commands.json
```

## Handling Authentication

When automating a site that requires login, choose the approach that fits:

**Option 1: Import auth from the user's browser (fastest for one-off tasks)**

```bash
# Connect to the user's running Chrome (they're already logged in)
agent-browser --auto-connect state save ./auth.json
# Use that auth state
agent-browser --state ./auth.json open https://app.example.com/dashboard
```

State files contain session tokens in plaintext -- add to `.gitignore` and delete when no longer needed. Set `AGENT_BROWSER_ENCRYPTION_KEY` for encryption at rest.

**Option 2: Chrome profile reuse (zero setup)**

```bash
# List available Chrome profiles
agent-browser profiles

# Reuse the user's existing Chrome login state
agent-browser --profile Default open https://gmail.com
```

**Option 3: Persistent profile (for recurring tasks)**

```bash
# First run: login manually or via automation
agent-browser --profile ~/.myapp open https://app.example.com/login
# ... fill credentials, submit ...

# All future runs: already authenticated
agent-browser --profile ~/.myapp open https://app.example.com/dashboard
```

**Option 4: Session name (auto-save/restore cookies + localStorage)**

```bash
agent-browser --session-name myapp open https://app.example.com/login
# ... login flow ...
agent-browser close  # State auto-saved

# Next time: state auto-restored
agent-browser --session-name myapp open https://app.example.com/dashboard
```

**Option 5: Auth vault (credentials stored encrypted, login by name)**

```bash
echo "$PASSWORD" | agent-browser auth save myapp --url https://app.example.com/login --username user --password-stdin
agent-browser auth login myapp
```

`auth login` navigates with `load` and then waits for login form selectors to appear before filling/clicking, which is more reliable on delayed SPA login screens.

**Option 6: State file (manual save/load)**

```bash
# After logging in:
agent-browser state save ./auth.json
# In a future session:
agent-browser state load ./auth.json
agent-browser open https://app.example.com/dashboard
```

See `references/authentication.md` for OAuth, 2FA, cookie-based auth, and token refresh patterns.

## Limitations

- **Image reading is most likely not available** - rely on snapshots and text content rather than screenshots for page analysis. Use `snapshot -i` for interactive elements and `get text` for content extraction.

## Essential Commands

```bash
# Navigation
agent-browser open <url>              # Navigate (aliases: goto, navigate)
agent-browser close                   # Close browser
agent-browser close --all             # Close all active sessions
agent-browser back                    # Go back
agent-browser forward                 # Go forward
agent-browser reload                  # Reload page
agent-browser pushstate <url>         # SPA client-side nav (auto-detects Next.js router)

# Snapshot
agent-browser snapshot -i             # Interactive elements with refs (recommended)
agent-browser snapshot -i --urls      # Include href URLs for links
agent-browser snapshot -s "#selector" # Scope to CSS selector

# Interaction (use @refs from snapshot)
agent-browser click @e1               # Click element
agent-browser click @e1 --new-tab     # Click and open in new tab
agent-browser dblclick @e1            # Double-click
agent-browser focus @e1               # Focus element
agent-browser fill @e2 "text"         # Clear and type text
agent-browser type @e2 "text"         # Type without clearing
agent-browser select @e1 "option"     # Select dropdown option
agent-browser check @e1               # Check checkbox
agent-browser uncheck @e1             # Uncheck checkbox
agent-browser press Enter             # Press key
agent-browser keydown Shift           # Hold key down
agent-browser keyup Shift             # Release held key
agent-browser keyboard type "text"    # Type at current focus (no selector)
agent-browser keyboard inserttext "text"  # Insert without key events
agent-browser scroll down 500         # Scroll page
agent-browser scroll down 500 --selector "div.content"  # Scroll within a specific container
agent-browser scrollintoview @e1      # Scroll element into view
agent-browser drag @e1 @e2            # Drag and drop
agent-browser upload @e1 file.pdf     # Upload files
agent-browser hover @e1               # Hover

# Get information
agent-browser get text @e1            # Get element text
agent-browser get html @e1            # Get innerHTML
agent-browser get value @e1           # Get input value
agent-browser get attr @e1 href       # Get attribute
agent-browser get title               # Get page title
agent-browser get url                 # Get current URL
agent-browser get cdp-url             # Get CDP WebSocket URL
agent-browser get count ".item"       # Count matching elements
agent-browser get box @e1             # Get bounding box
agent-browser get styles @e1          # Get computed styles

# Check state
agent-browser is visible @e1          # Check if visible
agent-browser is enabled @e1          # Check if enabled
agent-browser is checked @e1          # Check if checked

# Wait
agent-browser wait @e1                # Wait for element
agent-browser wait 2000               # Wait milliseconds
agent-browser wait --url "**/page"    # Wait for URL pattern
agent-browser wait --text "Welcome"   # Wait for text to appear (substring match)
agent-browser wait --load networkidle # Wait for network idle (caution: see Pitfalls)
agent-browser wait --fn "!document.body.innerText.includes('Loading...')"  # Wait for text to disappear
agent-browser wait "#spinner" --state hidden  # Wait for element to disappear

# Downloads
agent-browser download @e1 ./file.pdf          # Click element to trigger download
agent-browser wait --download ./output.zip     # Wait for any download to complete
agent-browser --download-path ./downloads open <url>  # Set default download directory

# Tab management
agent-browser tab list                         # List all open tabs (stable IDs: t1, t2, t3)
agent-browser tab new                          # Open a blank new tab
agent-browser tab new https://example.com      # Open URL in a new tab
agent-browser tab new --label docs             # Open tab with a custom label
agent-browser tab 2                            # Switch to tab by index (0-based)
agent-browser tab close                        # Close the current tab
agent-browser tab close 2                      # Close tab by index
agent-browser window new                       # New window

# Network
agent-browser network requests                 # Inspect tracked requests
agent-browser network requests --type xhr,fetch  # Filter by resource type
agent-browser network requests --method POST   # Filter by HTTP method
agent-browser network requests --status 2xx    # Filter by status (200, 2xx, 400-499)
agent-browser network request <requestId>      # View full request/response detail
agent-browser network route "**/api/*" --abort  # Block matching requests
agent-browser network route <url> --body '{}'  # Mock response
agent-browser network unroute [url]            # Remove routes
agent-browser network har start                # Start HAR recording
agent-browser network har stop ./capture.har   # Stop and save HAR file

# Viewport & Device Emulation
agent-browser set viewport 1920 1080          # Set viewport size (default: 1280x720)
agent-browser set viewport 1920 1080 2        # 2x retina (same CSS size, higher res screenshots)
agent-browser set device "iPhone 14"          # Emulate device (viewport + user agent)
agent-browser set geo 37.7749 -122.4194       # Set geolocation
agent-browser set offline on                  # Toggle offline mode
agent-browser set headers '{"X-Key":"v"}'     # Extra HTTP headers
agent-browser set credentials user pass       # HTTP basic auth
agent-browser set media dark                  # Emulate color scheme

# Capture
agent-browser screenshot              # Screenshot to temp dir
agent-browser screenshot path.png     # Save to file
agent-browser screenshot --full       # Full page screenshot
agent-browser screenshot --annotate   # Annotated screenshot with numbered element labels
agent-browser screenshot --screenshot-dir ./shots  # Save to custom directory
agent-browser screenshot --screenshot-format jpeg --screenshot-quality 80
agent-browser pdf output.pdf          # Save as PDF

# Mouse control
agent-browser mouse move 100 200      # Move mouse
agent-browser mouse down left         # Press button
agent-browser mouse up left           # Release button
agent-browser mouse wheel 100         # Scroll wheel

# Cookies & Storage
agent-browser cookies                     # Get all cookies
agent-browser cookies set name value      # Set cookie
agent-browser cookies clear               # Clear cookies
agent-browser storage local               # Get all localStorage
agent-browser storage local key           # Get specific key
agent-browser storage local set k v       # Set value
agent-browser storage local clear         # Clear all

# Clipboard
agent-browser clipboard read                      # Read text from clipboard
agent-browser clipboard write "Hello, World!"     # Write text to clipboard
agent-browser clipboard copy                      # Copy current selection
agent-browser clipboard paste                     # Paste from clipboard

# Dialogs (alert, confirm, prompt, beforeunload)
# By default, alert and beforeunload dialogs are auto-accepted so they never block the agent.
# confirm and prompt dialogs still require explicit handling.
# Use --no-auto-dialog (or AGENT_BROWSER_NO_AUTO_DIALOG=1) to disable automatic handling.
agent-browser dialog accept              # Accept dialog
agent-browser dialog accept "my input"   # Accept prompt dialog with text
agent-browser dialog dismiss             # Dismiss/cancel dialog
agent-browser dialog status              # Check if a dialog is currently open

# Frames
agent-browser frame "#iframe"     # Switch to iframe
agent-browser frame main          # Back to main frame

# Diff (compare page states)
agent-browser diff snapshot                          # Compare current vs last snapshot
agent-browser diff snapshot --baseline before.txt    # Compare current vs saved file
agent-browser diff screenshot --baseline before.png  # Visual pixel diff
agent-browser diff url <url1> <url2>                 # Compare two pages
agent-browser diff url <url1> <url2> --selector "#main"  # Scope to element

# Chat (AI natural language control)
agent-browser chat "open google.com and search for cats"  # Single-shot instruction
agent-browser chat                                        # Interactive REPL mode

# Streaming
agent-browser stream enable           # Start WebSocket streaming
agent-browser stream enable --port 9223  # Bind a specific port
agent-browser stream status           # Inspect streaming state
agent-browser stream disable          # Stop streaming

# Video recording
agent-browser record start ./demo.webm    # Start recording
agent-browser record stop                 # Stop and save video
agent-browser record restart ./take2.webm # Stop current + start new recording

# JavaScript evaluation
agent-browser eval "document.title"       # Run JavaScript
agent-browser eval --stdin <<'EVALEOF'    # Heredoc (avoids shell escaping)
JSON.stringify(document.querySelectorAll("img"))
EVALEOF
agent-browser eval -b "$(echo -n 'Array.from(document.querySelectorAll("a")).map(a => a.href)' | base64)"  # Base64

# Semantic locators (alternative to refs)
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find role button click --name "Submit"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click

# Live preview / observability
agent-browser dashboard start              # Start dashboard on port 4848
agent-browser dashboard stop               # Stop dashboard
```

## Efficiency Strategies

**Use `--urls` to avoid re-navigation.** When you need to visit links from a page, use `snapshot -i --urls` to get all href URLs upfront. Then `open` each URL directly instead of clicking refs and navigating back.

**Snapshot once, act many times.** Never re-snapshot the same page. Extract all needed info (refs, URLs, text) from a single snapshot, then batch the remaining actions.

**Multi-page workflow (e.g. "visit N sites and screenshot each"):**

```bash
# 1. Get all URLs in one call
agent-browser batch "open https://news.ycombinator.com" "snapshot -i --urls"
# Read output to extract URLs, then visit each directly:
# 2. One batch per target site
agent-browser batch "open https://github.com/example/repo" "screenshot"
agent-browser batch "open https://example.com/article" "screenshot"
agent-browser batch "open https://other.com/page" "screenshot"
```

## Ref Lifecycle

Refs (`@e1`, `@e2`, etc.) are invalidated when the page changes. Always re-snapshot after:

- Clicking links or buttons that navigate
- Form submissions
- Dynamic content loading (dropdowns, modals)

```bash
agent-browser click @e5              # Navigates to new page
agent-browser snapshot -i            # MUST re-snapshot
agent-browser click @e1              # Use new refs
```

## Annotated Screenshots (Vision Mode)

Use `--annotate` to take a screenshot with numbered labels overlaid on interactive elements. Each label `[N]` maps to ref `@eN`. This also caches refs, so you can interact with elements immediately without a separate snapshot.

```bash
agent-browser screenshot --annotate
# Output includes the image path and a legend:
#   [1] @e1 button "Submit"
#   [2] @e2 link "Home"
#   [3] @e3 textbox "Email"
agent-browser click @e2              # Click using ref from annotated screenshot
```

## Session Management

Named sessions provide isolation for parallel testing or when you need multiple browser instances:

```bash
agent-browser --session feature-test open http://localhost:3000
agent-browser --session feature-test snapshot -i
agent-browser --session feature-test close

# Parallel browsers
agent-browser --session test1 open site-a.com
agent-browser --session test2 open site-b.com
agent-browser session list
```

Session state persistence:

```bash
# Auto-save/restore cookies and localStorage across browser restarts
agent-browser --session-name myapp open https://app.example.com/login
# ... login flow ...
agent-browser close  # State auto-saved to ~/.agent-browser/sessions/

# Next time, state is auto-loaded
agent-browser --session-name myapp open https://app.example.com/dashboard

# Manage saved states
agent-browser state list
agent-browser state show myapp-default.json
agent-browser state clear myapp
agent-browser state clean --older-than 7
```

See `references/session-management.md` for details.

## Cloud Providers & Browser Engines

```bash
# Use cloud browser (agentcore, browserbase, browserless, browseruse, kernel)
agent-browser -p browserbase open example.com
# Or set AGENT_BROWSER_PROVIDER=browserbase

# Persistent profiles (retain cookies, localStorage across restarts)
agent-browser --profile myprofile open example.com

# Lightpanda engine (10x faster, 10x less memory than Chrome)
agent-browser --engine lightpanda open example.com

# Connect to existing Chrome
agent-browser --auto-connect open https://example.com
agent-browser --cdp 9222 snapshot

# Ignore HTTPS certificate errors (for local dev with self-signed certs)
agent-browser open https://localhost:8443 --ignore-https-errors
```

## Security

All security features are opt-in. By default, agent-browser imposes no restrictions.

### Content Boundaries (Recommended for AI Agents)

```bash
export AGENT_BROWSER_CONTENT_BOUNDARIES=1
agent-browser snapshot
# Output wrapped in nonce markers:
# --- AGENT_BROWSER_PAGE_CONTENT nonce=<hex> origin=https://example.com ---
# [accessibility tree]
# --- END_AGENT_BROWSER_PAGE_CONTENT nonce=<hex> ---
```

### Domain Allowlist

```bash
export AGENT_BROWSER_ALLOWED_DOMAINS="example.com,*.example.com"
agent-browser open https://example.com        # OK
agent-browser open https://malicious.com       # Blocked
```

### Action Policy

```bash
export AGENT_BROWSER_ACTION_POLICY=./policy.json
# policy.json: { "default": "deny", "allow": ["navigate", "snapshot", "click", "scroll", "wait", "get"] }
```

### Output Limits

```bash
export AGENT_BROWSER_MAX_OUTPUT=50000
```

## Timeouts and Slow Pages

The default timeout is 25 seconds. Override with `AGENT_BROWSER_DEFAULT_TIMEOUT` (milliseconds).

**`open` already waits for the page `load` event.** Only add an explicit wait when content loads asynchronously after the initial page load.

**Avoid `wait --load networkidle`** unless you are certain the site has no persistent network activity. Ad-heavy sites, analytics, and websockets will cause `networkidle` to hang indefinitely. Prefer `wait 2000` or `wait <selector>` instead.

## Working with Iframes

Iframe content is automatically inlined in snapshots. Refs inside iframes carry frame context, so you can interact with them directly.

```bash
agent-browser batch "open https://example.com/checkout" "snapshot -i"
# @e2 [Iframe] "payment-frame"
#   @e3 [input] "Card number"

# Interact directly -- no frame switch needed
agent-browser fill @e3 "4111111111111111"

# To scope a snapshot to one iframe:
agent-browser frame @e2
agent-browser snapshot -i
agent-browser frame main          # Return to main frame
```

## Configuration File

Create `agent-browser.json` in the project root for persistent settings:

```json
{
  "headed": true,
  "proxy": "http://localhost:8080",
  "profile": "./browser-data"
}
```

Priority (lowest to highest): `~/.agent-browser/config.json` < `./agent-browser.json` < env vars < CLI flags. All CLI options map to camelCase keys.

## Observability Dashboard

```bash
agent-browser dashboard start          # Start dashboard on port 4848
agent-browser open example.com         # All sessions auto-stream to dashboard
agent-browser dashboard stop           # Stop dashboard
```

The dashboard shows live browser viewports, command activity, and console output. Enable AI chat tab with:

```bash
export AI_GATEWAY_API_KEY=gw_your_key_here
export AI_GATEWAY_MODEL=anthropic/claude-sonnet-4.6
```

## Managing Dev Servers with PM2

When testing local apps, use PM2 to manage the dev server in the background.

**Philosophy:** Start once, keep running. Most dev servers have watch/hot-reload built in (`npm run dev`, `vite`, `next dev`, etc.) — they auto-reload on file changes. Don't stop between tests.

```bash
pm2 start "npm run dev" --name devserver   # Start (survives terminal close)
pm2 logs devserver                         # View logs
pm2 list                                   # Check status
pm2 delete devserver                       # Remove when done with project
```

## JSON output (for parsing)

Add `--json` for machine-readable output:

```bash
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

## Debugging

```bash
agent-browser --headed open example.com   # Show browser window
agent-browser console                     # View console messages
agent-browser console --clear             # Clear console
agent-browser errors                      # View page errors
agent-browser errors --clear              # Clear errors
agent-browser highlight @e1               # Highlight element
agent-browser inspect                     # Open Chrome DevTools
agent-browser trace start                 # Start recording trace
agent-browser trace stop trace.zip        # Stop and save trace
agent-browser profiler start              # Start Chrome DevTools profiling
agent-browser profiler stop trace.json    # Stop and save profile
agent-browser record start ./debug.webm   # Record from current page
agent-browser record stop                 # Save recording
agent-browser --cdp 9222 snapshot         # Connect via CDP
agent-browser connect <port>              # Connect to browser via CDP port
agent-browser addinitscript <js>          # Register init script at runtime
agent-browser removeinitscript <id>       # Remove registered init script
```

## React DevTools

Requires `open --enable react-devtools` at launch.

```bash
agent-browser react tree                  # Full component tree
agent-browser react inspect <fiberId>     # Props, hooks, state, source
agent-browser react renders start         # Start fiber render recording
agent-browser react renders stop          # Stop recording
agent-browser react suspense              # Suspense boundaries + classifier
agent-browser vitals [url]                # LCP/CLS/TTFB/FCP/INP + React hydration
```

## Diagnostics

```bash
agent-browser doctor                      # Environment diagnosis
agent-browser doctor --fix                # Auto-fix issues
agent-browser doctor --offline            # Skip network checks
agent-browser doctor --quick              # Fast check
agent-browser console                     # View console messages
agent-browser console --clear             # Clear console
agent-browser errors                      # View page errors
agent-browser errors --clear              # Clear errors
```

## References

For detailed guides, load as needed:

- `~/.agents/skills-opencode/browser-automation/references/workarounds.md` — **Platform fixes, complex editors, Shadow DOM, iframes**
- `~/.agents/skills-opencode/browser-automation/references/authentication.md` — Auth patterns
- `~/.agents/skills-opencode/browser-automation/references/session-management.md` — Session lifecycle
- `~/.agents/skills-opencode/browser-automation/references/snapshot-refs.md` — Snapshot refs explained
- `~/.agents/skills-opencode/browser-automation/references/proxy-support.md` — Proxy configuration
- `~/.agents/skills-opencode/browser-automation/references/video-recording.md` — Recording details

## Troubleshooting

### "Browser not launched" Error

Close any stale browser state and try again:

```bash
agent-browser close
agent-browser close --all
agent-browser open http://example.com
```

### Complex Editors (Monaco, CodeMirror, etc.)

`fill @ref` doesn't work with virtual editors. See `references/workarounds.md` for JavaScript solutions.

### Element Not Found After Interaction

Refs change after DOM updates. Always re-snapshot:

```bash
agent-browser click @e1
agent-browser snapshot -i  # Get fresh refs
```
