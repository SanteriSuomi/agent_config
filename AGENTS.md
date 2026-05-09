# AGENTS.md

Global rules for AI agents. Be concise — minimal code, minimal prose, minimal steps.

## Environment

```
~/.agents/                  # Source of truth (junctioned to ~/.claude/ and ~/.config/opencode/)
├── AGENTS.md               # This file (loaded every session)
├── agents/                 # Subagents: researcher, security-auditor
├── skills/                 # Auto-loading skills: browser-automation, context7-api, security
├── commands/               # Slash commands: /commit, /pr, /debug, /review
└── config/                 # Tool configs: opencode.json (MCP servers, providers)
```

OpenCode-first config. `~/.claude/` junctions kept for agent/skill discovery only.

**IMPORTANT:** Always modify files in `~/.agents/` — never in `~/.claude/` or `~/.config/opencode/`. Junctions ensure changes propagate automatically.

**Environment variables:** OpenCode MCP servers require API keys in the **process environment** (not `.env` files). Set as persistent user env vars: `[Environment]::SetEnvironmentVariable("KEY", "value", "User")`, then restart OpenCode. See `.env.example` for required keys.

**Platform:** Windows with Git Bash. Paths are case-sensitive for cross-platform compatibility.

**Git Bash quirks:**
- Path conversion: `/path` becomes `C:/Program Files/Git/path`. Use `MSYS_NO_PATHCONV=1` prefix for literal paths.
- Output capture: Shell wrappers may not capture output. Use `.cmd` suffix (e.g., `pnpm.cmd run test`).

## Code

- Explicit named imports, no wildcards or barrel files
- Case-sensitive paths always
- Strict mode, type-safe code
- Types must accurately reflect reality (optional fields should be `?`, nullable fields should include `| null`)
- Omit explicit return types unless needed for clarity or compiler requirements
- Constants: local if single-use, shared directory if reused

## Comments

**Only for:** exotic functions, workarounds, complex algorithms, "why" explanations.
**Never:** obvious code, redundant descriptions.

## Commits

- Imperative form ("Add feature" not "Added feature")
- Only commit when explicitly asked
- Run tests/lint first
- NEVER add watermarks, signatures, or "Co-Authored-By" lines

## Git

- Use `$env:GIT_EDITOR = "true"` before `git rebase --continue` to skip editor prompts on Windows
- Prefer `git pull --rebase` over `git pull` to avoid merge commits

## Testing

After changes, run in order (fail fast):
1. Type check → 2. Lint → 3. Unit tests → 4. Integration tests

For web apps: use `browser-automation` skill to verify UI changes work.

## Anti-Patterns

- Only make requested changes
- No unrequested features or refactoring
- No abstractions for one-time operations
- No error handling for impossible cases
- No hypothetical future design
- Three similar lines > premature abstraction

## Writing (Anti-Slop)

**Avoid:** throat-clearing ("In order to..."), emphasis crutches ("significantly"), tripling (always 3 items), AI words (delve, crucial, leverage, utilize, seamless, robust).

**Do:** Be specific, direct, varied rhythm. Have opinions. Acknowledge uncertainty.

## Web Search

Use current year (2026) in all searches.

## Context Management

**REQUIRED:** When starting any feature or task, use subagents for exploration and research. Do not consume main context with discovery work.

- **Explore agent:** codebase navigation, finding files, understanding architecture
- **Researcher agent:** web searches, documentation lookups, API references

Only run grep/glob/websearch directly in the main context when:
1. The query is trivial (single file lookup, known path)
2. Results are needed immediately for a decision already in progress

## Boundaries

**Always:** Use design-style for UI, run tests before commits, read files before modifying
**Ask First:** New dependencies, major refactors, architecture changes, deleting files
**Never:** Commit secrets, force push main, guess file contents, fabricate tool results

## Project Files

If a project has both `CLAUDE.md` and `AGENTS.md`, keep them in sync (identical content) unless explicitly said otherwise.
