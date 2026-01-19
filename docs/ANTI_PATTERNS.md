# Anti-Patterns to Avoid

## Over-Engineering

- Only make changes directly requested or clearly necessary
- **Avoid** adding unrequested features or refactoring
- **Avoid** adding error handling for scenarios that can't happen
- **Avoid** creating abstractions for one-time operations
- **Avoid** designing for hypothetical future requirements
- **Prefer** simple, direct code over clever abstractions
- Three similar lines of code is better than a premature abstraction
- **Avoid** wrapper functions unless they add real value (validation, error handling, logging)
- Inline simple logic rather than extracting to separate functions/files unnecessarily

## LOC Bloat

Signs of LOC bloat:
- Single-use abstractions
- Feature flags for hypothetical features
- Wrappers with no added value
- Over-parameterized functions
- Unnecessary type aliases
- Defensive code for impossible cases
- Premature optimizations
- Unnecessary interfaces
- Barrel files / index.ts re-exports

## Writing Style

See `WRITING_STYLE.md` for comprehensive anti-slop patterns.
