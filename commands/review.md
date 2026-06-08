# Review

Review current changes for architecture, security, and code quality.

$ARGUMENTS

---

## Steps

1. Run `git diff` and `git diff --cached` to see all changes
2. If $ARGUMENTS references specific files or paths, focus on those
3. Analyze for:
   - **Architecture**: structural soundness, separation of concerns, coupling, abstraction appropriateness
   - **Security**: injection, auth bypass, secrets, input validation (load `security` skill for security-sensitive code)
   - **Code quality**: logic errors, type safety, edge cases, missing error handling
   - **Testing**: missing tests for new logic
4. For each issue: file path, line number, severity (critical/high/medium/low), explanation, suggested fix
5. If no issues found, say "Looks good" with a brief summary

## Tone

Concise. Only flag real issues, not style preferences. Rank by severity.
