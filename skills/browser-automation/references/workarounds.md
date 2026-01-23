# Browser Automation Workarounds

Platform-specific fixes and workarounds for complex UI components.

## Windows Git Bash

### Problem: No stdout output from npm wrapper

The `agent-browser.cmd` wrapper doesn't produce output in Git Bash due to how the shim handles stdout.

### Solutions

**Option 1: Use direct executable (recommended)**
```bash
C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe --session test open http://localhost:3000
```

**Option 2: Create an alias**
```bash
# Add to ~/.bashrc
alias ab='C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe'

# Usage
ab --session test open http://localhost:3000
```

**Option 3: Use PowerShell**
The `.ps1` wrapper works correctly in PowerShell terminals.

---

## Complex Text Editors

### Monaco Editor (VS Code-based)

Monaco creates a virtual textarea that doesn't respond to standard `fill` commands.

**Problem:**
```bash
agent-browser --session test fill @textbox "content"  # Doesn't work
```

**Solution: Use JavaScript eval**
```bash
# Set content
agent-browser --session test eval "window.monaco?.editor?.getModels()?.[0]?.setValue('new content')"

# Get content
agent-browser --session test eval "window.monaco?.editor?.getModels()?.[0]?.getValue()"

# Insert at cursor
agent-browser --session test eval "window.monaco?.editor?.getEditors()?.[0]?.trigger('keyboard', 'type', {text: 'inserted text'})"
```

### CodeMirror

Similar to Monaco, CodeMirror uses a virtual editing surface.

**Solution:**
```bash
# CodeMirror 6
agent-browser --session test eval "document.querySelector('.cm-content')?.cmView?.view?.dispatch({changes: {from: 0, to: view.state.doc.length, insert: 'new content'}})"

# CodeMirror 5
agent-browser --session test eval "document.querySelector('.CodeMirror')?.CodeMirror?.setValue('new content')"
```

### Ace Editor

```bash
agent-browser --session test eval "ace.edit(document.querySelector('.ace_editor'))?.setValue('new content')"
```

### ProseMirror / TipTap

```bash
agent-browser --session test eval "document.querySelector('.ProseMirror')?.pmViewDesc?.view?.dispatch(view.state.tr.insertText('content'))"
```

### Quill

```bash
agent-browser --session test eval "document.querySelector('.ql-editor')?.__quill?.setText('new content')"
```

---

## Rich Text / WYSIWYG Editors

For contenteditable elements that don't respond to `fill`:

```bash
# Focus and use keyboard
agent-browser --session test click @editor
agent-browser --session test press Control+a
agent-browser --session test type "new content"

# Or use execCommand (older browsers)
agent-browser --session test eval "document.execCommand('selectAll'); document.execCommand('insertText', false, 'new content')"
```

---

## File Upload Workarounds

### Hidden file inputs

Some sites hide file inputs. Find and interact directly:

```bash
agent-browser --session test eval "document.querySelector('input[type=file]').style.display = 'block'"
agent-browser --session test upload "input[type=file]" ./file.pdf
```

### Drag-and-drop upload zones

```bash
# Simulate file drop via JavaScript
agent-browser --session test eval "
const dt = new DataTransfer();
dt.items.add(new File(['content'], 'test.txt', {type: 'text/plain'}));
const dropzone = document.querySelector('.dropzone');
dropzone.dispatchEvent(new DragEvent('drop', {dataTransfer: dt, bubbles: true}));
"
```

---

## Shadow DOM

Elements inside Shadow DOM aren't in the main accessibility tree.

```bash
# Pierce shadow DOM with eval
agent-browser --session test eval "document.querySelector('my-component').shadowRoot.querySelector('button').click()"
```

---

## Iframes

### Cross-origin iframes

Can't access cross-origin iframe content directly. Options:

1. Use `frame` command if same-origin
2. Navigate directly to iframe URL
3. Use network interception to modify iframe content

### Same-origin iframes

```bash
agent-browser --session test frame "#my-iframe"
agent-browser --session test snapshot -i
agent-browser --session test click @e1
agent-browser --session test frame main  # Return to main
```

---

## Canvas / WebGL

Canvas content isn't in accessibility tree. Options:

1. Screenshot and describe visually (if image reading available)
2. Use JavaScript to query canvas state
3. Interact with controls outside canvas

```bash
# Get canvas data
agent-browser --session test eval "document.querySelector('canvas').toDataURL()"
```

---

## Lazy-loaded Content

Content that loads on scroll:

```bash
agent-browser --session test scroll down 1000
agent-browser --session test wait 1000
agent-browser --session test snapshot -i  # Now includes new content
```

---

## Infinite Scroll

```bash
# Scroll to bottom repeatedly
agent-browser --session test eval "
let lastHeight = 0;
const scroll = () => {
  window.scrollTo(0, document.body.scrollHeight);
  if (document.body.scrollHeight > lastHeight) {
    lastHeight = document.body.scrollHeight;
    setTimeout(scroll, 1000);
  }
};
scroll();
"
```

---

## Anti-bot Detection

Some sites detect automation. Mitigations:

```bash
# Use realistic user agent
agent-browser --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --session test open example.com

# Add human-like delays
agent-browser --session test click @e1
agent-browser --session test wait 500
agent-browser --session test fill @e2 "text"

# Use persistent profile (has history, cookies)
agent-browser --profile ~/.browser-profile --session test open example.com
```

---

## Popups and New Windows

```bash
# Handle popup by switching tabs
agent-browser --session test click @popup-trigger
agent-browser --session test wait 1000
agent-browser --session test tab 2  # Switch to new tab
agent-browser --session test snapshot -i
```

---

## Date/Time Pickers

Most date pickers have hidden inputs. Set directly:

```bash
agent-browser --session test eval "document.querySelector('input[type=date]').value = '2024-01-15'"
agent-browser --session test eval "document.querySelector('input[type=date]').dispatchEvent(new Event('change', {bubbles: true}))"
```

---

## Select2 / Chosen / Custom Dropdowns

These replace native selects with custom UI:

```bash
# Click to open, then click option
agent-browser --session test click ".select2-selection"
agent-browser --session test wait 500
agent-browser --session test snapshot -i
agent-browser --session test click @option

# Or set value directly
agent-browser --session test eval "$('#my-select').val('option-value').trigger('change')"
```
