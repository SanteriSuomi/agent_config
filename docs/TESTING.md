# Testing Philosophy

## Change Testing

- Run tests, linting, and type checking on changes to verify nothing breaks
- Fix failing tests or errors before committing

## Feedback Loop Priority

Run checks in priority order (fail fast on cheapest):

1. **Type/syntax checking** - fastest, catches most errors
2. **Linting** - style issues and potential bugs
3. **Unit tests** - verifies behavior
4. **Integration tests** - verifies system behavior
5. **Environment tests** - verify in actual runtime context

After changes, run available quality commands. Fix failures before proceeding.

## Environment-Specific Tests

| Project Type | Environment Test |
|--------------|------------------|
| Web app | Dev server + browser automation |
| API/backend | Run server + test endpoints |
| CLI/script | Execute with test inputs |
| Desktop app | Launch and interact via automation |
| Library | Unit tests + example usage |

## Coverage

- Test the new functionality, edge cases, and error states
- Follow existing test patterns in the codebase
- For changes to existing features, run existing tests first
