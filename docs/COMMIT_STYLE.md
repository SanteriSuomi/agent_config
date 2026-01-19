# Commit Guidelines

## Message Format

- **Prefer** imperative verb form (e.g., "Add feature" not "Added feature")
- **Prefer** shorter, focused commits over large, monolithic changes
- Multi-line format: summary followed by bulleted changes

### Example

```
Add user authentication

- Implement JWT token generation
- Add login/logout endpoints
- Update API documentation
```

## Commit Rules

- Only commit when explicitly requested
- Run tests/lint/typecheck before suggesting commits
- Verify message format matches repository style (check recent commits)

## Anti-Patterns

Avoid:
- Watermarks, signatures, or attribution in commit messages
- Overly verbose descriptions
- Combining unrelated changes in one commit
