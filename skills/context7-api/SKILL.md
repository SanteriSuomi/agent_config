---
name: context7-api
description: "Context7 API for up-to-date library documentation. Use proactively when working with unfamiliar libraries or APIs, or when implementation requires current docs. Also use when users ask for docs, examples, or API references. Triggers: 'how do I use [library]', 'docs for', '[library] documentation', 'show me examples', 'what is the API for'."
---

# Context7 API

Retrieve up-to-date library documentation via Context7 REST API.

## When to Use

- Need official documentation for a library or framework
- Looking for API references, usage examples, best practices
- Troubleshooting library-specific issues
- Need current documentation (not outdated)

## API Endpoints

Base URL: `https://context7.com/api`

### 1. Search Libraries

```
GET https://context7.com/api/v1/search?q={query}
```

Example:
```bash
curl "https://context7.com/api/v1/search?q=react%20hooks"
```

### 2. Get Library Documentation

```
GET https://context7.com/api/v1/library/{library_id}
```

### 3. Get Code Snippets

```
GET https://context7.com/api/v1/snippets?library={library}&topic={topic}
```

## Usage Pattern

1. **Search** for the library/topic
2. **Fetch** detailed documentation using library ID
3. **Extract** relevant code snippets

## Example Workflow

```
User: "How do I use React Server Components?"

1. WebSearch: "React Server Components documentation 2026"
2. WebFetch: https://context7.com/api/v1/search?q=react+server+components
3. Parse response for library_id
4. WebFetch: https://context7.com/api/v1/library/{library_id}
5. Return summarized findings
```

## Output Format

When returning documentation:

```markdown
## [Library/Topic]

**Source**: [URL]

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

## Fallback

If Context7 API is unavailable:
1. Use `WebSearch` with "[library] official documentation 2026"
2. Use `WebFetch` on official docs sites
