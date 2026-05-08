# Commit

Analyze current changes and create a well-structured commit.

$ARGUMENTS

---

## Steps

1. Run `git status` and `git diff` to understand all changes
2. Run `git diff --cached` for staged changes
3. If nothing staged and nothing unstaged, say "Nothing to commit" and stop
4. If unstaged changes exist, `git add` the relevant files
5. Write a commit message in imperative form (e.g., "Add auth validation" not "Added")
6. Keep the first line under 72 chars
7. Do NOT add Co-Authored-By, AI watermarks, or signatures
8. If $ARGUMENTS provided, incorporate into the message
9. Commit with `git commit -m "..."`
10. Run `git status` after to confirm

## Rules

- Imperative form only ("Add feature" not "Added feature")
- One commit per logical change — don't batch unrelated changes
- NEVER force push, amend, or use --no-verify
- NEVER commit files with secrets, credentials, or .env files
