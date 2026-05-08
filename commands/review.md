# Review

Review current uncommitted changes for potential issues.

$ARGUMENTS

---

## Steps

1. Run `git diff` and `git diff --cached` to see all changes
2. If $ARGUMENTS references specific files or paths, focus on those
3. Analyze for:
   - Logic errors and off-by-one mistakes
   - Missing error handling
   - Type safety issues
   - Security vulnerabilities (injection, auth bypass, secrets)
   - Performance implications
   - Edge cases not covered
   - Missing tests for new logic
4. For each issue found: file path, line number, severity, explanation, suggested fix
5. If no issues found, say "Looks good" with a brief summary of what changed

## Tone

Concise. Only flag real issues, not style preferences. Rank by severity.
