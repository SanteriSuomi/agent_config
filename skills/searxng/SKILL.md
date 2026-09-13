---
name: searxng
description: "Search the live web via the self-hosted SearXNG instance (private, no API keys). Use when a task needs current information, recent releases or news, version checks, or web verification beyond training data. NOT for local codebase questions (use grep/glob) or GitHub repo research (use the gh-repos skill)."
compatibility: "Requires curl (native on Windows 10+/Linux). No Python needed — agents parse the JSON response natively; jq is optional for trimming large responses. Instance reachable at http://searxng.home.arpa (plain HTTP — TLS removed; LAN/Tailscale-only network) on the Fedora host; from other machines use the host LAN IP (http://192.168.0.233) if the .home.arpa name does not resolve."
license: "MIT"
metadata:
  version: "1.0.0"
---

# SearXNG Web Search

Search the web through the local SearXNG instance. No API keys, no rate
limits beyond engine behavior, queries stay on the LAN (engines see the
instance's fingerprinted requests, not the agent's).

## Canonical invocation

```bash
curl -s -G "http://searxng.home.arpa/search" \
  --data-urlencode "q=YOUR QUERY HERE" \
  --data-urlencode "format=json"
```

Read the JSON directly: `results[]` (title/url/content) and `infoboxes[]`
(wikipedia lands there by design). Self-trim — don't dump more than needed
into context.

For very large responses, trim with jq instead of reading raw:

```bash
curl -s -G "http://searxng.home.arpa/search" \
  --data-urlencode "q=YOUR QUERY HERE" \
  --data-urlencode "format=json" |
jq -r '(.results[:10][] | "* \(.title)\n  \(.url)\n  \((.content // "")[0:160])"), (.infoboxes[]? | "INFOBOX: \(.infobox) - \((.content // "") | tostring | .[0:280])")'
```

Notes:
- `-G` + `--data-urlencode` handles query encoding correctly. Never inline raw
  queries with spaces/special chars.
- Parse **both** `results` and `infoboxes` — wikipedia results land in
  `infoboxes[]` by design (display_type: infobox).
- On Windows PowerShell, `ConvertFrom-Json` works if jq is unavailable.

## Useful parameters

| Param | Example | Purpose |
|---|---|---|
| `engines` | `engines=brave` | Query one engine (URL-encode names with spaces: `google%20cse`) |
| `language` | `language=en` | Force language (wikipedia routes per-language) |
| `pageno` | `pageno=2` | Pagination |
| `categories` | `categories=news` | Restrict category |

## Engine status (checked 2026-09-07, post-curl_cffi migration)

| Engine | State | Notes |
|---|---|---|
| google cse | reliable, ~20 results | primary workhorse |
| brave | reliable, ~10-20 | revived by browser-fingerprint networking |
| duckduckgo | intermittent | CAPTCHAs until upstream fix lands; retries sometimes pass |
| wikipedia | reliable | results arrive as infoboxes |
| mojeek | currently 403 | watch; re-check before relying on it |
| qwant | disabled | CAPTCHA-prone, left off |

Tolerate engine failures: a query returning results from 2-3 engines is
normal. Only treat a total failure (0 results, empty infoboxes) as an error.

## Failure modes

- **Empty everything**: instance down or JSON format disabled → check
  `docker ps --filter name=searxng` and retry once; then fall back to the
  web-search-prime MCP.
- **0 results on a niche query**: try broader terms before assuming breakage;
  check whether the engines you expected are in the contributing set.
- **Slow (>10s)**: retry once; engines may be temporarily suspended
  (bot-wall bans expire in hours).

## Verification

- Spot-check 2-3 returned URLs actually resolve before citing them.
- Follow conventions in `references/web-research.md` (repo root:
  `~/agent_config` on Fedora, `~/.agents` on Windows).
