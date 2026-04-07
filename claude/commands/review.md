---
description: Conduct a six-axis code review — correctness, readability, architecture, security, performance, maintainability
---

Invoke the agent-skills:code-review-and-quality skill and spawn the code-reviewer agent to perform a thorough review.

## Scope

Review the current changes (use `git diff` for unstaged, `git diff --cached` for staged, or `git log -1 -p` for the last commit). If a PR number is provided as `$ARGUMENTS`, review that PR instead via `gh pr diff`.

## Review Process

1. **Understand context first** — Read the diff, understand what and why before judging how.
2. **Review tests first** — Tests reveal intent. Check they exist, test behavior (not implementation), and cover edge cases.
3. **Evaluate across six axes:**
   - **Correctness** — Matches spec? Edge cases and error paths handled? Tests adequate?
   - **Readability** — Clear names? Straightforward logic? No unnecessary complexity? Dead code removed?
   - **Architecture** — Follows existing patterns? Clean module boundaries? Right abstraction level?
   - **Security** — Input validated at boundaries? Secrets safe? Auth checked? External data untrusted?
   - **Performance** — No N+1 queries? No unbounded ops? Pagination present?
   - **Maintainability** — No TODO/FIXME debt? No deprecated APIs? Technical debt reduced?

## Severity Labels

Every finding must be categorized:

- **Critical:** — Blocks merge. Security vulnerability, data loss, broken functionality.
- _(no prefix)_ — Required change. Must address before merge.
- **Nit:** — Minor, optional. Author may ignore.
- **Optional:** / **Consider:** — Suggestion worth considering but not required.
- **FYI** — Informational only. No action needed.

## Output Format

```markdown
## Review Summary

**Verdict:** APPROVE | REQUEST CHANGES

**Overview:** [1-2 sentences on the change and overall assessment]

### Critical Issues
- [file:line] Description and recommended fix

### Important Issues
- [file:line] Description and recommended fix

### Suggestions
- [file:line] Description

### What's Done Well
- [Specific positive observation — always include at least one]

### Dead Code Check
- [List any orphaned code introduced or left behind by the change]

### Verification
- Tests: [pass/fail/missing]
- Build: [pass/fail]
- Security: [checked/concerns]
```

## Principles

- **Approve when it improves code health** — don't block for perfection.
- **Don't rubber-stamp** — "LGTM" without evidence helps no one.
- **Quantify problems** — "adds ~50ms per item" beats "could be slow."
- **Push back honestly** — sycophancy is a review failure mode.
- **Don't accept "I'll fix it later"** — it never happens.
