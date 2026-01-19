# AGENTS.md

General guidance for AI agents on this computer.

## Just-In-Time Reference

Load relevant docs based on current task:

- Writing code? → `docs/CODE_STYLE.md`
- Adding comments? → `docs/COMMENTS.md`
- Adding logging? → `docs/LOGGING.md`
- Running tests? → `docs/TESTING.md`
- Making commits? → `docs/COMMIT_STYLE.md`
- Building UI? → `docs/DESIGN_STYLE.md`
- Setting up project? → `docs/PROJECT_SETUP.md`
- Avoiding bloat? → `docs/ANTI_PATTERNS.md`
- Writing prose? → `docs/WRITING_STYLE.md`

## Critical Rules (Always Apply)

1. **Read files before proposing changes** - understand existing patterns first
2. **No over-engineering** - only make changes directly requested or clearly necessary
3. **Use current year in web searches** - for package versions, documentation, APIs
4. **Prefer established libraries** - over custom implementations
5. **Check existing patterns** - before creating new utilities or abstractions

## Project Discovery

Check project's dependency manifest for tech stack and framework. Look for config files in project root (tsconfig, eslint, cargo.toml, go.mod, etc.).

## UI Development

When building user interfaces:
- **Design tokens**: See `docs/DESIGN_STYLE.md`
- **Build patterns**: Use `ui-patterns` skill
- **Validation**: Run `design-review` after building
