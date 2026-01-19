# Comment Guidelines

## Philosophy

Code should be self-documenting through clear naming. **AVOID** littering the codebase with unnecessary comments.

## When to Comment

Only add comments for:

1. **Exotic/unusual functions** - that aren't obvious
2. **Workarounds/hacks** - that need explanation
3. **Complex algorithms** - where intent isn't clear from code
4. **"Why" explanations** - when the "what" is clear but reasoning isn't

## Anti-Patterns

Never comment obvious code:
- `// increment counter`
- `// return the result`
- `// check if valid`

## Writing Style (Anti-Slop)

**Avoid AI writing patterns:**
- **Throat-clearing** - "In order to...", "It's important to note..."
- **Emphasis crutches** - "significantly", "notably", "essentially"
- **Tripling** - Always listing exactly 3 things when 1-2 would suffice
- **Business jargon** - "leverage", "utilize", "facilitate", "streamline", "robust"

**Write directly:**
- Start with the action or point
- Trust the reader - don't over-explain
- Use active voice - "Run tests" not "Tests should be run"
- Be specific - "Takes 2 seconds" not "Takes a moment"
