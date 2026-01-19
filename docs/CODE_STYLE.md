# Code Style

## Import Practices

- **Prefer** explicit named imports over namespace or wildcard imports
- Improves code readability, tree-shaking, and makes dependencies explicit
- **Avoid** barrel files or magic re-exports that hide actual source locations
- Import directly from source files to make dependencies traceable

## File Path Portability

- File paths and import paths should match the exact case of filenames
- Windows is case-insensitive, but Linux and macOS are case-sensitive
- Use platform-agnostic path separators where possible (e.g., `/` in web contexts, `path.join()` in native code)

## Constants

- If used in only one file, define constants locally in that file
- If used in multiple files, place in a dedicated constants directory
- Group related constants together

## Type Safety & Static Analysis

- **Enable** strict mode or equivalent static analysis settings
- **Prefer** type-safe code over dynamic/loosely-typed approaches
- Place type definitions at the top of files, after imports
- Place constants at the top of files, after type definitions
- **Prefer** inferred return types when possible. Explicit return types only for:
  - Recursive functions
  - Function overloads
  - When type inference genuinely fails
- Extract repeated values to local constants (e.g., `const now = new Date()`)

## Dependency Management

- Use locked dependency versions for reproducible builds
- Pin versions unless there's explicit reason to allow ranges

## Use Established Libraries

- **Prefer** well-maintained libraries over custom implementations
- Only write custom code for simple or one-off tasks where library overhead isn't justified
