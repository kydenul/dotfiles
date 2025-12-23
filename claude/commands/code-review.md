# Claude Command: Code Review

This command invokes the specialized code-reviewer agent to perform comprehensive code reviews of your changes. It analyzes code quality, security vulnerabilities, performance issues, and best practices compliance.

## Usage

To perform a code review of your current changes, type:

```
/code-review
```

Or with options:

```
/code-review --scope staged
/code-review --scope all
/code-review --focus security
```

## What This Command Does

1. **Analyzes Git Changes**: Examines staged or unstaged changes in your repository
2. **Invokes Code Reviewer Agent**: Uses the specialized `code-reviewer` agent for systematic analysis
3. **Comprehensive Review**: Performs multi-faceted analysis covering:
   - Code quality and maintainability
   - Security vulnerabilities and best practices
   - Performance bottlenecks and optimization opportunities
   - Design patterns and architectural decisions
   - Documentation completeness and clarity
4. **Provides Actionable Feedback**: Delivers specific improvement suggestions with examples
5. **Prioritizes Issues**: Identifies critical, major, and minor issues with clear recommendations

## Integration with Code Reviewer Agent

This command acts as a convenient interface to the comprehensive code review workflow defined in `/claude/agents/code-reviewer.md`. When invoked, it:

- Automatically detects the scope of changes (staged vs unstaged files)
- Configures the code-reviewer agent with appropriate context
- Applies the systematic review checklist from the agent
- Provides structured feedback following established review patterns

The code-reviewer agent handles the detailed review logic, while this command provides an easy-to-use interface for developers.

## Review Scope Options

### Default Behavior
By default, the command reviews:
- Staged changes if any files are staged
- All modified files if no files are staged
- Untracked files are excluded unless explicitly included

### Scope Options
- `--scope staged`: Review only staged changes
- `--scope all`: Review all modified files (staged and unstaged)
- `--scope files <file1,file2,...>`: Review specific files only

### Focus Areas
- `--focus security`: Emphasize security vulnerabilities and best practices
- `--focus performance`: Focus on performance optimization opportunities
- `--focus quality`: Emphasize code quality and maintainability
- `--focus documentation`: Review documentation completeness and clarity

## Review Categories

The code review covers these key areas:

### Code Quality Assessment
- Logic correctness and error handling
- Code organization and structure
- Function complexity and duplication
- Naming conventions and readability
- SOLID principles compliance

### Security Review
- Input validation and sanitization
- Authentication and authorization checks
- Injection vulnerabilities prevention
- Cryptographic practices
- Sensitive data handling

### Performance Analysis
- Algorithm efficiency and optimization
- Memory usage and resource management
- Database query optimization
- Network call efficiency
- Caching effectiveness

### Design Patterns
- Appropriate pattern usage
- Abstraction levels and coupling
- Extensibility and maintainability
- Interface design and contracts

### Documentation Review
- Code comments and inline documentation
- API documentation completeness
- README files and usage examples
- Architecture documentation

## Best Practices for Code Reviews

### Review Timing
- **Pre-commit**: Review changes before committing to catch issues early
- **Pre-PR**: Review before creating pull requests to ensure quality
- **Regular**: Schedule regular reviews for ongoing maintenance

### Review Focus Areas
- **Critical First**: Address security and critical functionality issues first
- **Constructive Feedback**: Provide specific, actionable improvement suggestions
- **Positive Reinforcement**: Acknowledge good practices and well-implemented features
- **Learning Opportunity**: Use reviews as knowledge sharing moments

### Effective Review Patterns
- Start with high-level architectural review
- Focus on critical security and performance issues
- Provide specific examples and alternative solutions
- Prioritize feedback by impact and effort
- Follow up on implemented suggestions

## Examples

### Basic Usage
```
/code-review
```
Reviews all current changes with balanced focus on all categories.

### Security-Focused Review
```
/code-review --focus security --scope all
```
Reviews all modified files with emphasis on security vulnerabilities.

### Specific File Review
```
/code-review --scope files src/main.go,src/utils.go
```
Reviews only the specified files for targeted analysis.

### Pre-Commit Review
```
/code-review --scope staged
```
Reviews only staged changes before committing.

## Command Options

- `--scope <scope>`: Define review scope (staged, all, files)
- `--focus <area>`: Set review focus area (security, performance, quality, documentation)
- `--verbose`: Provide detailed analysis with more examples
- `--quick`: Fast review focusing on critical issues only

## Expected Output Format

The command provides structured feedback in this format:

```
## Code Review Report

### Executive Summary
- Overall Assessment: [PASS/NEEDS IMPROVEMENT/CRITICAL]
- Critical Issues: [count]
- Major Issues: [count]
- Minor Issues: [count]

### Critical Issues
- [Issue description with specific file:line references]
- [Actionable improvement suggestions]

### Major Issues
- [Issue description with specific examples]
- [Recommended fixes]

### Minor Issues
- [Code quality suggestions]
- [Best practices recommendations]

### Positive Aspects
- [Well-implemented features]
- [Good practices observed]

### Recommendations Summary
- [Priority action items]
- [Suggested next steps]
```

## Common Use Cases

### Pre-Commit Quality Check
Use before committing changes to ensure code quality and catch issues early.

### Pull Request Preparation
Review changes before creating PRs to reduce review cycles and improve code quality.

### Learning and Improvement
Use as a learning tool to understand code quality standards and best practices.

### Team Standards Enforcement
Ensure consistent coding standards across team members and projects.

## Troubleshooting

### No Changes Detected
If no changes are detected, ensure you have:
- Modified files in your working directory
- Staged changes if using `--scope staged`
- Valid file paths if using `--scope files`

### Agent Integration Issues
If the code-reviewer agent fails to load:
- Verify the agent file exists at `/claude/agents/code-reviewer.md`
- Check for syntax errors in the agent configuration
- Ensure proper agent permissions and access

### Performance Considerations
For large codebases:
- Use `--quick` option for faster reviews
- Limit scope with `--scope files` for targeted analysis
- Consider reviewing changes in smaller increments

## Related Resources

- **Code Reviewer Agent**: `/claude/agents/code-reviewer.md` - Detailed review logic and checklists
- **Commit Command**: `/claude/commands/commit.md` - For creating well-formatted commits after review
- **CLAUDE.md**: Repository overview and configuration guidelines

## Best Practices Reminder

- **Regular Reviews**: Incorporate code reviews into your development workflow
- **Constructive Approach**: Focus on improvement rather than criticism
- **Continuous Learning**: Use feedback to enhance your coding skills
- **Team Collaboration**: Share review insights to improve team standards
