---
name: context7-api
description: "Documentation lookup using Context7 REST API for library documentation."
---

# Context7 API

Use Context7 REST API for up-to-date library documentation retrieval via direct HTTP requests.

## When to Use

- Need official documentation for a library or framework
- Looking for API references, usage examples, best practices
- Need current year's documentation (always include year in queries)
- Troubleshooting with library-specific issues

## When NOT to Use

- For codebase-specific patterns (use Grep/Read instead)
- When offline or API rate limited
- For internal/proprietary libraries not in Context7
- For simple syntax lookups (use inline knowledge)

## API Endpoints

### 1. Search for Libraries

Search Context7's library catalog:

```bash
curl "https://context7.com/api/v2/libs/search?libraryName=nextjs&query=routing" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

**Parameters:**

- `libraryName`: Library name to search (required, e.g., 'react', 'nextjs', 'express')
- `query`: User's original question or task (required, used for intelligent relevance ranking)

**Response:**

```json
{
  "results": [
    {
      "id": "/vercel/next.js",
      "title": "Next.js",
      "description": "The React Framework for the Web",
      "branch": "canary",
      "lastUpdateDate": "2025-01-15T10:30:00.000Z",
      "state": "finalized",
      "totalTokens": 500000,
      "totalSnippets": 2500,
      "stars": 115000,
      "trustScore": 10,
      "benchmarkScore": 95.5,
      "versions": ["v15.0.0", "v14.2.0"]
    }
  ]
}
```

### 2. Get Documentation Context

Retrieve documentation for a specific library:

```bash
curl "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=How%20to%20setup%20middleware" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

**Parameters:**

- `libraryId`: Context7 library ID in format `/owner/repo` or `/owner/repo/version` (from search, required)
- `query`: User's original question or task (required, used for intelligent relevance ranking)
- `type`: Response format type (optional, default: `txt`, options: `json`, `txt`)

**With specific version:**

```bash
curl "https://context7.com/api/v2/context?libraryId=/vercel/next.js/v15.1.8&query=app%20router" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

**Response:**

```json
{
  "codeSnippets": [
    {
      "codeTitle": "Middleware Authentication Example",
      "codeDescription": "Shows how to implement authentication checks in Next.js middleware",
      "codeLanguage": "typescript",
      "codeTokens": 150,
      "codeId": "https://github.com/vercel/next.js/blob/canary/docs/middleware.mdx#_snippet_0",
      "pageTitle": "Middleware",
      "codeList": [
        {
          "language": "typescript",
          "code": "import { NextResponse } from 'next/server'\nimport type { NextRequest } from 'next/server'\n\nexport function middleware(request: NextRequest) {\n  const token = request.cookies.get('token')\n  if (!token) {\n    return NextResponse.redirect(new URL('/login', request.url))\n  }\n  return NextResponse.next()\n}"
        }
      ]
    }
  ],
  "infoSnippets": [
    {
      "pageId": "https://github.com/vercel/next.js/blob/canary/docs/middleware.mdx",
      "breadcrumb": "Routing > Middleware",
      "content": "Middleware allows you to run code before a request is completed...",
      "contentTokens": 200
    }
  ]
}
```

## Authentication

All requests require API key in Authorization header:

```
Authorization: Bearer CONTEXT7_API_KEY
```

Get your API key at: https://context7.com/dashboard

API keys should start with `ctx7sk`

## Usage with WebFetch

Using WebFetch tool (preferred for integration):

```javascript
// Search for library
const searchResponse = await webfetch({
  url: "https://context7.com/api/v2/libs/search?libraryName=nextjs&query=routing",
  format: "json",
  headers: {
    Authorization: `Bearer ${process.env.CONTEXT7_API_KEY}`,
  },
});

// Get documentation
const docsResponse = await webfetch({
  url: "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=How%20to%20implement%20authentication",
  format: "json",
  headers: {
    Authorization: `Bearer ${process.env.CONTEXT7_API_KEY}`,
  },
});
```

## Usage with Bash/Curl

Using Bash tool for direct API calls:

```bash
# Set API key
export CONTEXT7_API_KEY="your_api_key_here"

# Search for library
curl -s "https://context7.com/api/v2/libs/search?libraryName=react&query=state" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"

# Get documentation
curl -s "https://context7.com/api/v2/context?libraryId=/facebook/react&query=useState%20hook" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

## Error Handling

**Common HTTP Status Codes:**

- `200` - Success
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (invalid API key)
- `404` - Library not found
- `422` - Library too large or no code available
- `429` - Rate limit exceeded (wait with exponential backoff)
- `500` - Internal server error (retry with backoff)

**Error Response Format:**

```json
{
  "error": "library_not_found",
  "message": "Library \"/owner/repo\" not found."
}
```

## Rate Limits

- **Without API key**: Low limits
- **With API key**: Higher limits based on plan
- **429 status**: Too many requests, wait for `Retry-After` header

## Best Practices

1. **Be specific with queries**: Use detailed, natural language questions
2. **Use specific versions**: Pin to exact versions for consistency
3. **Cache responses**: Documentation updates infrequently, cache for hours/days
4. **Handle rate limits**: Implement exponential backoff for 429 errors
5. **Include current year**: Always include current year in searches for up-to-date info

## Examples

### Example 1: Next.js Middleware

```bash
# Search library
curl "https://context7.com/api/v2/libs/search?libraryName=nextjs" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"

# Get docs with specific query
curl "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=Create%20middleware%20to%20check%20JWT%202025" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

### Example 2: React Hooks

```bash
curl "https://context7.com/api/v2/context?libraryId=/facebook/react&query=How%20to%20use%20useEffect%20with%20dependencies%202025" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

### Example 3: Specific Version

```bash
curl "https://context7.com/api/v2/context?libraryId=/tailwindlabs/tailwindcss/v3.4.0&query=Config%20file%20options%202025" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

## Output Format

### Library Search Response

Array of matching libraries ranked by relevance, containing:

- `id`: Context7 library ID (e.g., `/vercel/next.js`)
- `title`: Library name
- `description`: Library description
- `state`: Finalization status (`finalized`, `processing`)
- `versions`: Available versions
- `stars`: GitHub stars count
- `trustScore`: Trust score (1-10)
- `benchmarkScore`: Quality score
- `totalTokens`: Documentation token count

### Documentation Context Response

Relevant documentation containing:

- `codeSnippets`: Array of relevant code examples
  - `codeTitle`: Title of the code snippet
  - `codeDescription`: Description of what code demonstrates
  - `codeLanguage`: Programming language
  - `codeList`: Array of code blocks with language and content
- `infoSnippets`: Array of documentation sections
  - `pageId`: Source page URL
  - `breadcrumb`: Documentation path
  - `content`: Text content
  - `contentTokens`: Content length in tokens
- `rules` (optional): Library-specific rules/constraints

### Usage Notes

- **Always include current year** in queries for up-to-date information
- **Be specific**: Detailed questions get better results
- **Pin versions**: Use `/owner/repo/version` for consistent results
- **Handle errors**: Implement retry logic for rate limits (429)
