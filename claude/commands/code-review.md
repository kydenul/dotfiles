# Code Review Command

Perform a thorough code review of the specified files or recent changes.

## Usage

```
/code-review [file or diff]
```

## What This Command Does

1. Identifies the scope of review:
   - If a file path is provided, reviews that file
   - Otherwise, reviews the current branch diff against main/master
2. Evaluates the code across five dimensions:
   - **Correctness** — logic errors, edge cases, off-by-ones
   - **Readability** — naming, comments, complexity
   - **Architecture** — separation of concerns, abstractions, coupling
   - **Security** — input validation, injection risks, auth issues
   - **Performance** — unnecessary allocations, N+1 queries, hot paths
3. Reports only high-confidence issues with file + line references
4. Suggests concrete fixes, not just observations

## Output Format

```
## [Dimension] — Severity: HIGH / MEDIUM / LOW
File: path/to/file.go:42
Issue: <what is wrong>
Fix:   <what to do instead>
```

## Guidelines

- Prioritize issues by severity: HIGH → MEDIUM → LOW
- Do not flag style preferences as bugs
- If the change is clean, say so explicitly — no issues is a valid result
- Keep feedback actionable and specific
