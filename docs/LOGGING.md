# Logging Guidelines

> Note: These are preferences, especially for larger projects. Adapt based on project needs.

## Principles

- **Prefer** structured logging (JSON key-value pairs) over strings for query ability
- **Prefer** wide events - one comprehensive event per request with all context
- **Include** business context: user_id, request_id, trace_id and relevant metrics
- **Ensure** actionability - every log should answer a specific question or aid debugging
- **Avoid** verbosity - keep logs concise; reserve verbose output for debug level only

## Example Pattern

```json
{
  "timestamp": "2024-01-15T10:23:45.612Z",
  "request_id": "req_8bf7ec2d",
  "trace_id": "abc123",
  "user_id": "user_456",
  "event": "process_completed",
  "status_code": 200,
  "duration_ms": 1247,
  "steps": {
    "parse_thread": { "duration_ms": 234, "status": "success" },
    "find_video": { "duration_ms": 892, "status": "success" },
    "download": { "duration_ms": 1247, "status": "success" }
  }
}
```

Steps can be nested under any context (jobs, services, requests, workflows) to track operation phases.
