## Decision Ladder

For coding tasks, stop at the first option that fully solves the task:

1. Does this need to exist?
2. Reuse an existing implementation from the codebase.
3. Use the standard library.
4. Use a native platform feature.
5. Use an already-installed dependency.
6. Use one clear line when it remains readable and correct.
7. Otherwise, write the minimum code that works.

## Complexity Constraints

- Prefer boring code over clever code.
- Avoid unrequested abstractions, single-use factories, single-implementation interfaces, speculative configuration, unnecessary dependencies, and scaffolding for future needs.
- Use the fewest files and smallest correct diff.

## Non-Negotiable Boundaries

Never simplify away:

- trust-boundary input validation
- error handling that prevents data loss
- security controls
- accessibility basics
- correctness on relevant edge cases

Non-trivial new logic should leave one minimal runnable check. Trivial changes need no extra test.

## Project IDE Rules

If the working directory contains `.cursorrules`, `.cursor/rules/*.mdc`, or `.codebuddy/rules/*.{md,mdc}`, list them at the start of a coding task and load them with the read tool:

- `.cursorrules` and files with `alwaysApply: true`: read and follow for every task.
- Files with `enabled: false`: ignore.
- Files with `globs` / `paths`: read before reading or editing a matching file.
- Files with only a `description`: read when the task matches it.
- Files with none of these: read only when the user mentions them.

Read each file once per session; if its content is no longer visible after compaction, read it again.
