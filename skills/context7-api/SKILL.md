---
name: context7-api
description: "Context7 API for up-to-date library documentation. Use proactively when working with unfamiliar libraries or APIs, or when implementation requires current docs. Also use when users ask for docs, examples, or API references. Triggers: 'how do I use [library]', 'docs for', '[library] documentation', 'show me examples', 'what is the API for'."
license: MIT
---

# Context7 API

Retrieve up-to-date library documentation via Context7 REST API v2.

## When to Use

- Need official documentation for a library or framework
- Looking for API references, usage examples, best practices
- Troubleshooting library-specific issues
- Need current documentation (not outdated training data)

## API Endpoints

Base URL: `https://context7.com/api`

### 1. Search Libraries

```
GET https://context7.com/api/v2/libs/search?libraryName={name}&query={topic}
```

Both `libraryName` and `query` are required.

```bash
curl "https://context7.com/api/v2/libs/search?libraryName=react&query=hooks"
```

Response: array of `results` with `id`, `title`, `description`, `versions`.

### 2. Get Documentation Context

```
GET https://context7.com/api/v2/context?libraryId={id}&query={topic}
```

- `libraryId` — from search results. Supports multiple formats:
  - `/owner/repo` — GitHub/GitLab/Bitbucket repos (e.g. `/facebook/react`)
  - `/npm/<name>` or `/packages/<name>` — npm packages
  - `/websites/<id>` — websites
  - `/llmstxt/<source>` — llms.txt sources
  - `/docs/<name>` — uploaded docs
- `query` — specific topic within the library

```bash
curl "https://context7.com/api/v2/context?libraryId=/facebook/react&query=useState"
```

Response: `codeSnippets[]` + `infoSnippets[]`. Default format is `txt`; add `&type=json` for structured JSON.

### Version Pinning

Append `@version` or `/version` to the library ID:

```
/vercel/next.js@v15.1.8
/vercel/next.js/v15.1.8
```

### Additional Parameters

- `fast=true` — skip LLM reranking (lower latency, lower relevance)
- `tokens=number` — limit response tokens (e.g. `tokens=5000` for focused queries)

### Response Fields

- `codeSnippets[]` — code examples with optional `isDynamic` and `sourceFile` fields
- `infoSnippets[]` — text documentation
- `rules` — optional object with `global`, `libraryOwn`, `libraryTeam` arrays containing library-specific guidelines

### Authentication

`Authorization: Bearer CONTEXT7_API_KEY` — optional for search/context (rate-limited without), required for management endpoints. Keys start with `ctx7sk` prefix.

## Usage Pattern

1. **Search** for the library with a topic query
2. **Extract** `libraryId` from results
3. **Fetch** documentation context using `libraryId` + refined query
4. **Summarize** relevant findings

## Example Workflow

```
User: "How do I use React Server Components?"

1. WebFetch: https://context7.com/api/v2/libs/search?libraryName=react&query=server+components
2. Parse response → libraryId = "/facebook/react"
3. WebFetch: https://context7.com/api/v2/context?libraryId=/facebook/react&query=server+components
4. Return summarized findings
```

## Output Format

When returning documentation:

```markdown
## [Library/Topic]

**Source**: Context7 API

### Key Concepts
- [Concept 1]
- [Concept 2]

### Code Example
\`\`\`typescript
// Example code
\`\`\`

### Best Practices
- [Practice 1]
- [Practice 2]
```

## When NOT to Use

- Simple syntax questions the model already knows
- Standard library features (use training knowledge)
- When user provides their own docs/links

## Anti-Patterns

| Anti-Pattern | Why | Instead |
|--------------|-----|---------|
| Fetching without a focused query | Token waste, slow | Be specific in `query` param |
| Ignoring search results | May fetch wrong library | Verify `libraryId` matches intent |
| No fallback on failure | API may be down | Always have WebSearch fallback |
| Fetching without summarizing | Overwhelms user | Extract key points only |
| Using v1 endpoints | Deprecated, returns 400 | Always use `/api/v2/` paths |

## Error Handling

```
API returns 202        → Library accepted but not finalized — wait and retry
API returns 301        → Library redirected — follow redirectUrl in response
API returns 400        → Likely v1 endpoint — use v2 paths
API returns 402        → Spending limit exceeded
API returns 403        → Access denied or plan restriction
API returns 404        → Library not indexed, use WebSearch fallback
API returns 422        → Library too large or no code found
API returns 429        → Rate limited, wait or use fallback
API returns empty      → Broaden libraryName or query terms
Network timeout        → Use cached knowledge + warn user
```

## Fallback

If Context7 API is unavailable:
1. Use `WebSearch` with "[library] official documentation [year]"
2. Use `WebFetch` on official docs sites
3. Clearly state: "Using web search (Context7 unavailable)"
