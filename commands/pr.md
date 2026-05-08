# Pull Request

Create a pull request from the current branch.

$ARGUMENTS

---

## Steps

1. Run `git status` — if uncommitted changes exist, ask whether to commit first
2. Run `git log main..HEAD --oneline` (or master) to see all branch commits
3. Run `git diff main...HEAD` for the full diff
4. Analyze all changes and draft a PR summary
5. Detect git remote type and available CLI tools:
   - Check if `gh` is available (GitHub)
   - Check if `glab` is available (GitLab)
   - Check if `tea` is available (Gitea)
   - If no CLI tool found, open the compare URL in the browser
6. Push the branch if not already tracking: `git push -u origin HEAD`
7. Create the PR using the detected tool
8. Title: imperative form, concise
9. Body: Summary section with bullet points of key changes
10. If $ARGUMENTS provided, incorporate into the description

## Rules

- NEVER force push or use --no-verify
- Detect the base branch (main/master) from the remote
- If no CLI tool is available, construct and output the compare URL
