---
name: web-reader
description: "Extract clean main content from web pages as markdown using trafilatura (local, no API). Use when reading articles, documentation, or long pages — especially when webfetch output is too noisy (navigation, footers, cookie banners survive) or truncated. NOT for images (use webfetch) or search (use the searxng skill)."
compatibility: "Windows (no system Python): `uvx trafilatura --markdown -u URL` (uv required). Linux/brew: use the `trafilatura` binary. pip installs: `python -m trafilatura` with trafilatura==2.2.0 pinned."
license: "MIT"
metadata:
  version: "1.0.0"
---

# Web Reader (trafilatura)

Read a URL and get the main content as clean markdown — boilerplate,
navigation, and cookie banners removed. This is the quality path for
article-class reads; built-in `webfetch` remains fine for quick checks
and images.

## Canonical invocation

```bash
uvx trafilatura --markdown -u "https://example.com/article"     # Windows canonical (no python needed)
trafilatura --markdown -u "https://example.com/article"          # Linux/brew binary
```

- URLs go via `-u` (positional args are NOT accepted in 2.2.0).
- Pinned version: **trafilatura==2.2.0** (`pip install trafilatura==2.2.0`).
- Linux (brew install): use the `trafilatura` binary directly — `python3 -m
  trafilatura` may not resolve the brew module.
- Windows (pip install): `python -m trafilatura --markdown -u URL`.
- Useful flags: `--no-tables` (skip table extraction), `--precision` /
  `--recall` (lean vs aggressive extraction; default is balanced).

## When to use what

| Situation | Tool |
|---|---|
| Article, docs page, blog post, wiki page | this skill |
| Quick check, status endpoint, raw JSON/XML | built-in `webfetch` |
| Image URL (vision input) | built-in `webfetch` (returns image attachment) |
| Search for pages | `searxng` skill |

## Failure modes

- **Empty or near-empty output**: page is JS-rendered (SPA), paywalled, or
  blocked. Mark the source `unverified-extraction` and fall back to
  `webfetch`; if that also fails, report the page unreadable. Never
  reconstruct page content from memory — that is fabrication.
- **Partial content** (article cut mid-way): extraction boundary missed;
  try `--recall`, or note the truncation in your output.
- **Command missing**: install per compatibility note, or use `uvx trafilatura`.

## Verification

- If output looks too short for the source, treat as partial (see above).
- Follow `references/web-research.md` conventions (repo root:
  `~/agent_config` on Fedora, `~/.agents` on Windows) — trafilatura-extracted
  text counts as *fetched direct* in the source register.
