# Debug

Debug an error by tracing through the codebase.

$ARGUMENTS

---

## Steps

1. Identify the error type and location from the stack trace or description
2. Read the file(s) mentioned in the error
3. Trace the data flow backward — where did the bad value come from?
4. Check for common causes: null/undefined, type mismatches, race conditions, missing null checks, off-by-one errors
5. Identify the root cause (not just the symptom)
6. Propose a minimal fix
7. Apply the fix
8. Detect test framework and run relevant tests to verify
9. If tests fail, iterate on the fix

## Approach

Think like a detective. Follow the evidence. Don't guess — read the code.

- Start from the error, trace backward through calls/data flow
- Check types at each boundary
- Verify assumptions by reading actual values
- Fix the root cause, not the symptom
