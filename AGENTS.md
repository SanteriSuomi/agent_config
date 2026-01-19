# AGENTS.md

General guidance for AI agents on this computer.

## Just-In-Time Reference

Load relevant docs based on current task:

- Writing code? → `~/.agents/docs/CODE_STYLE.md`
- Adding comments? → `~/.agents/docs/COMMENTS.md`
- Adding logging? → `~/.agents/docs/LOGGING.md`
- Running tests? → `~/.agents/docs/TESTING.md`
- Making commits? → `~/.agents/docs/COMMIT_STYLE.md`
- Building UI? → `~/.agents/docs/DESIGN_STYLE.md`
- Setting up project? → `~/.agents/docs/PROJECT_SETUP.md`
- Avoiding bloat? → `~/.agents/docs/ANTI_PATTERNS.md`
- Writing prose? → `~/.agents/docs/WRITING_STYLE.md`
- Writing a README? → `~/.agents/docs/README.md`

## Critical Rules (Always Apply)

1. **Read files before proposing changes** - understand existing patterns first
2. **No over-engineering** - only make changes directly requested or clearly necessary
3. **ALWAYS use current year (and month for fast-moving topics) in web searches** - for package versions, documentation, APIs, best practices. Only omit if it would explicitly harm the search results.
4. **Prefer established libraries** - over custom implementations
5. **Check existing patterns** - before creating new utilities or abstractions

## Project Discovery

Check project's dependency manifest for tech stack and framework. Look for config files in project root (tsconfig, eslint, cargo.toml, go.mod, etc.).

## UI Development

When building user interfaces:
- **Design tokens**: See `~/.agents/docs/DESIGN_STYLE.md`
- **Build patterns**: Use `ui-patterns` skill
- **Validation**: Run `design-review` after building
