# AGENTS.md

Global rules for AI agents. Be concise — minimal code, minimal prose, minimal steps.

## Environment

```
~/.agents/                  # Source of truth (symlinked to ~/.claude/, ~/.config/opencode/)
├── AGENTS.md               # This file (loaded every session)
├── agents/                 # Subagents: researcher, implementer, code-quality, security-auditor
├── skills/                 # Auto-loading contextual skills
├── commands/               # Slash commands
└── hooks/                  # Automation hooks
```

**Platform:** Windows with Git Bash. Paths are case-sensitive for cross-platform compatibility.

## Code

- Explicit named imports, no wildcards or barrel files
- Case-sensitive paths always
- Strict mode, type-safe code
- Constants: local if single-use, shared directory if reused

## Comments

**Only for:** exotic functions, workarounds, complex algorithms, "why" explanations.
**Never:** obvious code, redundant descriptions.

## Commits

- Imperative form ("Add feature" not "Added feature")
- Only commit when explicitly asked
- Run tests/lint first
- No watermarks or signatures

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

## Boundaries

**Always:** Use design-style for UI, run tests before commits, read files before modifying
**Ask First:** New dependencies, major refactors, architecture changes, deleting files
**Never:** Commit secrets, force push main, guess file contents, fabricate tool results
