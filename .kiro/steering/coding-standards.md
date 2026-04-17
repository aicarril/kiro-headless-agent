---
inclusion: auto
---

# Coding Standards & Developer Guidelines

These standards apply to ALL code in this repository. Every developer and agent must follow them.

## Python Standards

- Use Python 3.11+
- Type hints required on all function signatures
- Docstrings required on all public functions (Google style)
- Max line length: 120 characters
- Use `pathlib` over `os.path`
- Use f-strings over `.format()` or `%`
- No bare `except:` — always catch specific exceptions
- Use `logging` module, never `print()` in production code
- Imports ordered: stdlib → third-party → local (enforced by isort rules)

## YAML Standards

- 2-space indentation (no tabs)
- Always quote strings that could be misinterpreted (yes/no, on/off, true/false)
- Use block style for multi-line strings (`|` or `>`)
- No trailing whitespace
- Document separator `---` at the top of every file
- Anchors and aliases encouraged for DRY configs
- CloudFormation/CDK templates: always include `Description` field

## SQL / Athena Standards

- Keywords in UPPERCASE (`SELECT`, `FROM`, `WHERE`, `JOIN`)
- Table aliases required for all JOINs
- Always use explicit `JOIN` syntax (never comma joins)
- Partition pruning required — every Athena query MUST filter on partition keys
- Avoid `SELECT *` — list columns explicitly
- CTEs preferred over nested subqueries
- Target query execution: < 50ms for dashboards, < 500ms for reports

## Infrastructure / IaC Standards

- All resources must have tags: `Environment`, `Team`, `Service`, `CostCenter`
- No hardcoded ARNs, account IDs, or regions — use parameters/variables
- IAM: least privilege, no `*` in resource unless justified with a comment
- All secrets in AWS Secrets Manager or SSM Parameter Store
- CloudWatch alarms required for all critical paths

## Git Practices

- Branch naming: `feature/<ticket-id>-<short-description>` or `fix/<ticket-id>-<short-description>`
- Commit messages: `[<component>] <imperative description>` (e.g., `[api] Add pagination to list endpoint`)
- One logical change per commit
- No force pushes to `main`
- Feature branches must pass all checks before merge

## Code Review Checklist (used by CI Review Agent)

1. Does the code follow the language-specific standards above?
2. Are there any security issues? (hardcoded secrets, SQL injection, open permissions)
3. Are error cases handled?
4. Are there type hints / proper typing?
5. Is the code DRY? Any obvious duplication?
6. Are YAML files properly formatted?
7. Do SQL queries use partition pruning?
8. Are all resources properly tagged?
