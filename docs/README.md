# README Style Guide

## Philosophy

A README exists to answer: "What is this, and how do I use it?"

## Essential sections

| Section | Required | Purpose |
|---------|----------|---------|
| Title | Yes | Project name, one line |
| Description | Yes | 1-2 sentences explaining what it does |
| Installation | Yes | Commands to get it running |
| Usage | Yes | Basic example of how to use it |
| License | Yes | Legal terms (can be one line) |
| Contributing | Optional | Link to CONTRIBUTING.md if exists |
| API/Docs | Optional | Link out to detailed docs |

## Writing the description

**Do:**
- State what the project does in one sentence
- Mention the primary use case
- Include key differentiator if relevant

**Avoid:**
- Starting with "This is a..."
- Marketing language ("revolutionary", "blazing fast")
- Listing every feature upfront

**Examples:**

| Bad | Good |
|-----|------|
| "This is a revolutionary CLI tool that leverages AI to streamline your workflow" | "CLI tool for generating commit messages from diffs" |
| "A robust, scalable solution for..." | "Queue library for Node.js with Redis backend" |

## Installation and usage

- Show the actual commands, not prose about them
- Use code blocks with language hints
- One happy path example is enough for the README

```bash
# Install
npm install thing

# Run
thing --input file.txt
```

**Avoid** showing every flag and option. Link to `--help` or docs instead.

## Badges

**Use 2-4 max.** More badges = visual noise.

| Worth including | Skip |
|-----------------|------|
| Build status (if public CI) | Code style badges |
| npm/PyPI version | "Made with X" badges |
| License | Social badges |
| Test coverage (if meaningful) | Decorative badges |

Place badges on one line, directly under the title.

## What belongs elsewhere

| Content | Where it goes |
|---------|---------------|
| Contribution guidelines | CONTRIBUTING.md |
| Detailed API reference | /docs or wiki |
| Changelog | CHANGELOG.md |
| Security policy | SECURITY.md |
| Code of conduct | CODE_OF_CONDUCT.md |
| Architecture decisions | /docs/adr or similar |

Link to these from the README. Don't inline them.

## Anti-patterns

| Pattern | Problem |
|---------|---------|
| Wall of badges | Visual noise, rarely useful |
| Giant feature list upfront | Buries the actual usage |
| Screenshots before explaining what it is | Context-free visuals |
| ASCII art logos | Accessibility issues, wastes vertical space |
| "Table of Contents" for short READMEs | Over-organization |
| Emojis as section markers | Inconsistent rendering, visual clutter |
| "Prerequisites" section listing obvious tools | Noise (if it needs Node, saying "install Node" is redundant) |
| Inline installation for every package manager | Pick one, link to others |

## Formatting

- **Sentence case** for headings ("Getting started" not "Getting Started")
- **Code blocks** for all commands and code
- **One blank line** between sections
- **No trailing whitespace**
- Keep line length reasonable (~80-100 chars in prose)

## Quick checklist

Before publishing:

1. Can someone understand what this does in 30 seconds?
2. Can they install and run a basic example in 2 minutes?
3. Do they know where to find more details?
4. Is the license clear?

If yes to all, the README is done. Stop adding to it.
