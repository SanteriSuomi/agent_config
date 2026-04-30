# README Style Guide

## Writing the Description

**Do:**
- State what the project does in one sentence
- Mention the primary use case
- Include key differentiator if relevant

**Avoid:**
- Starting with "This is a..."
- Marketing language ("revolutionary", "blazing fast")
- Listing every feature upfront

| Bad | Good |
|-----|------|
| "This is a revolutionary CLI tool that leverages AI..." | "CLI tool for generating commit messages from diffs" |
| "A robust, scalable solution for..." | "Queue library for Node.js with Redis backend" |

---

## Installation & Usage

- Show actual commands, not prose about them
- Use code blocks with language hints
- One happy path example is enough

```bash
# Install
npm install thing

# Run
thing --input file.txt
```

Avoid showing every flag. Link to `--help` or docs.

---

## Badges

**Use 2-4 max.** More = visual noise.

| Worth including | Skip |
|-----------------|------|
| Build status (if public CI) | Code style badges |
| npm/PyPI version | "Made with X" badges |
| License | Social badges |
| Test coverage (if meaningful) | Decorative badges |

Place on one line, directly under the title.

---

## What Belongs Elsewhere

| Content | Where |
|---------|-------|
| Contribution guidelines | CONTRIBUTING.md |
| Detailed API reference | /docs or wiki |
| Changelog | CHANGELOG.md |
| Security policy | SECURITY.md |
| Architecture decisions | /docs/adr |

Link to these from README. Don't inline them.

---

## Anti-patterns

| Pattern | Problem |
|---------|---------|
| Wall of badges | Visual noise |
| Giant feature list upfront | Buries usage |
| Screenshots before explaining | Context-free |
| ASCII art logos | Accessibility, wastes space |
| TOC for short READMEs | Over-organization |
| Emojis as section markers | Inconsistent rendering |
| "Prerequisites" for obvious tools | Noise |
| Inline install for every package manager | Pick one, link others |

---

## Formatting

- **Sentence case** for headings ("Getting started" not "Getting Started")
- **Code blocks** for all commands and code
- **One blank line** between sections
- Keep line length ~80-100 chars in prose

---

## Quick Checklist

Before publishing:

1. Can someone understand what this does in 30 seconds?
2. Can they install and run a basic example in 2 minutes?
3. Do they know where to find more details?
4. Is the license clear?

If yes to all, the README is done. Stop adding to it.
