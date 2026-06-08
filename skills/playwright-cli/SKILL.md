---
name: playwright-cli
description: "Browser automation with persistent page state. Use proactively when relevant (e.g., testing web app features during development, verifying UI changes, E2E testing). Also use when users ask to navigate websites, fill forms, take screenshots, extract web data, or automate browser workflows. Triggers: go to [url], open website, visit, click on, fill form, screenshot, scrape, test the website, log into."
allowed-tools: Bash(playwright-cli:*), Bash(npx:*)
---

# Browser Automation with playwright-cli

Fast browser automation CLI for AI agents. Built on Playwright with first-class
Windows support. Accessibility-tree snapshots with `eN` refs for compact interaction.

## The core loop

```bash
playwright-cli -s=myapp open <url>     # 1. Open a page (named session)
playwright-cli -s=myapp snapshot       # 2. See what's on it
playwright-cli -s=myapp click e3       # 3. Act on refs from the snapshot
playwright-cli -s=myapp snapshot       # 4. Re-snapshot after any page change
```

Refs (`e1`, `e2`, ...) are assigned fresh on every snapshot. They become
**stale the moment the page changes** — after clicks that navigate, form
submits, dynamic re-renders, dialog opens. Always re-snapshot before your
next ref interaction.

## Named sessions

**Always use named sessions (`-s=<name>`)** to avoid conflicts when multiple
agents or tasks may run browser automation in parallel.

```bash
playwright-cli -s=test open http://localhost:5173
playwright-cli -s=test snapshot
playwright-cli -s=test fill e5 "user@example.com"
playwright-cli -s=test click e6
playwright-cli -s=test close
```

## Installation

```bash
npm install -g @playwright/cli@latest
playwright-cli install                     # detect system Chrome/Edge
playwright-cli install-browser chromium    # fallback: download Chromium
```

`playwright-cli install` detects installed browsers. If Chrome or Edge is
on the system, no additional download needed. Otherwise `install-browser`
downloads Chromium (~150 MB).

**Pre-1.0 software** — run `npm install -g @playwright/cli@latest` to stay
current.

## Quickstart

```bash
playwright-cli -s=demo open https://example.com
playwright-cli -s=demo snapshot
playwright-cli -s=demo screenshot --filename=home.png
playwright-cli -s=demo close
```

## Reading a page

```bash
playwright-cli -s=demo snapshot                   # full tree with refs
playwright-cli -s=demo snapshot --depth=4          # limit depth
playwright-cli -s=demo snapshot "#main"            # scope to CSS selector
```

Snapshot output looks like:

```
### Page
- Page URL: https://example.com/login
- Page Title: Example - Log in
### Snapshot
```yaml
- generic [ref=e2]:
  - heading "Log in" [level=1] [ref=e3]
  - textbox "Email" [ref=e4]:
    - /placeholder: you@example.com
  - textbox "Password" [ref=e5]:
    - /placeholder: ••••••••
  - button "Sign In" [ref=e6]
```

## Interacting

```bash
playwright-cli -s=demo click e3                   # click
playwright-cli -s=demo fill e4 "hello"            # clear then type
playwright-cli -s=demo select e5 "option-value"   # select dropdown
playwright-cli -s=demo check e6                   # check checkbox
playwright-cli -s=demo upload ./document.pdf       # upload file
playwright-cli -s=demo press Enter                 # press a key
```

### When refs don't work

Use CSS selectors or Playwright locators:

```bash
playwright-cli -s=demo click "#submit"
playwright-cli -s=demo click "getByRole('button', { name: 'Submit' })"
playwright-cli -s=demo click "getByTestId('submit-btn')"
```

## Waiting

```bash
playwright-cli -s=demo wait --text "Success"           # until text appears
playwright-cli -s=demo wait --url "**/dashboard"       # until URL matches
playwright-cli -s=demo wait --load networkidle         # until network idle
playwright-cli -s=demo wait 2000                       # dumb wait (last resort)
```

After any page-changing action, re-snapshot. Avoid bare `wait N` except when
debugging.

## Common workflows

### Log in

```bash
playwright-cli -s=auth open https://app.example.com/login
playwright-cli -s=auth snapshot
playwright-cli -s=auth fill e4 "user@example.com"
playwright-cli -s=auth fill e5 "password123"
playwright-cli -s=auth click e6
playwright-cli -s=auth wait --url "**/dashboard"
playwright-cli -s=auth snapshot
```

### Persist session

```bash
# Save auth state after logging in
playwright-cli -s=auth state-save auth.json

# Restore in a new session
playwright-cli -s=auth2 state-load auth.json
playwright-cli -s=auth2 open https://app.example.com/dashboard
```

### Screenshot

```bash
playwright-cli -s=demo screenshot                     # temp path
playwright-cli -s=demo screenshot --filename=page.png # specific path
```

### Interactive UI review

```bash
playwright-cli -s=demo show --annotate
```

Opens a visual dashboard where the user can annotate the page with feedback.
Useful for design reviews and gathering UI feedback.

## Multiple sessions

```bash
# Parallel sessions with full isolation
playwright-cli -s=alice open https://app.example.com
playwright-cli -s=bob open https://app.example.com

# List active sessions
playwright-cli list

# Close specific session
playwright-cli -s=alice close

# Close all
playwright-cli close-all

# Force-kill orphaned processes
playwright-cli kill-all
```

## Network mocking

```bash
playwright-cli -s=demo route "**/api/users" --body='{"users":[]}'
playwright-cli -s=demo route "**/analytics" --status=404
playwright-cli -s=demo requests
playwright-cli -s=demo unroute
```

## Headed mode

Default is headless. Use `--headed` for debugging:

```bash
playwright-cli -s=demo open --headed https://example.com
```

## DevTools

```bash
playwright-cli -s=demo console                 # console messages
playwright-cli -s=demo console warning         # warnings only
playwright-cli -s=demo requests                # network requests
playwright-cli -s=demo request 5               # specific request details
playwright-cli -s=demo eval "document.title"   # run JS
```

## Cleanup

Always close sessions when done:

```bash
playwright-cli -s=demo close        # close named session
playwright-cli close-all            # close all sessions
playwright-cli kill-all             # force-kill all daemon processes
```

If orphaned browser processes remain after `kill-all`:

```bash
taskkill //F //IM chrome.exe 2>/dev/null
```

## Windows notes

- Detects system Chrome/Edge — no Chromium download needed in most cases
- Named sessions use named pipes for IPC — stable in current versions
- If sessions hang, `kill-all` is the recovery mechanism
- URL parameters with `&` should be quoted in shell

## Full reference

See [references/](references/) for detailed guides:

- **[session-management.md](references/session-management.md)** — named sessions, persistent profiles, attaching to running browsers
- **[storage-state.md](references/storage-state.md)** — cookies, localStorage, sessionStorage
- **[running-code.md](references/running-code.md)** — running Playwright code, complex scripts
- **[playwright-tests.md](references/playwright-tests.md)** — running and debugging Playwright tests
- **[spec-driven-testing.md](references/spec-driven-testing.md)** — plan / generate / heal test specs
- **[test-generation.md](references/test-generation.md)** — generating tests from interactions
- **[element-attributes.md](references/element-attributes.md)** — inspecting element attributes
- **[request-mocking.md](references/request-mocking.md)** — network interception and mocking
- **[tracing.md](references/tracing.md)** — trace recording and analysis
- **[video-recording.md](references/video-recording.md)** — video capture options
