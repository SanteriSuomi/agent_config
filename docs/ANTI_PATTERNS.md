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

## Writing Style (Anti-Slop)

When writing documentation, comments, UI copy, or commit messages:

**Avoid AI writing patterns:**
- **Throat-clearing** - "In order to...", "It's important to note...", "As you can see..."
- **Emphasis crutches** - "significantly", "notably", "essentially", "incredibly"
- **Tripling** - Always listing exactly 3 things when 1-2 would suffice
- **Announcements** - "Let me explain...", "I'll now show you..."
- **Business jargon** - "leverage", "utilize", "facilitate", "streamline", "robust"

**Write directly:**
- Start with the action or point
- Trust the reader - don't over-explain
- Use active voice
- Be specific
- Vary list lengths - use 1, 2, 4, or 5 items, not always 3
