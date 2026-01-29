# Debug Tricks

## MCP Endpoint for AI-Assisted Debugging

Next.js provides a `/_next/mcp` endpoint during development that leverages the Model Context Protocol.

### Availability

- **Next.js 16+**: Built-in
- **Earlier versions**: Enable `experimental.mcpServer: true` in config

### Available Tools

| Tool | Purpose |
|------|---------|
| `get_errors` | Current build and runtime errors with source-mapped stack traces |
| `get_routes` | Scans filesystem to discover all available routes |
| `get_project_metadata` | Returns project path and dev server URL |
| `get_page_metadata` | Runtime data about current page rendering |
| `get_logs` | Points to Next.js development log file location |
| `get_server_action_by_id` | Locates specific Server Actions by identifier |

### Usage

The endpoint communicates via JSON-RPC 2.0 over HTTP POST.

**Important**: Find the actual port of the running Next.js dev server (check terminal output or `package.json` scripts). Don't assume port 3000.

## Selective Route Rebuilding

Next.js 16+ introduces `--debug-build-paths` for targeted rebuilds.

```bash
# Rebuild specific routes instead of full build
next build --debug-build-paths "/blog/[slug]" "/api/users"

# Use glob patterns
next build --debug-build-paths "/blog/**"
```

This accelerates iteration when addressing build errors or static generation problems on specific routes.
