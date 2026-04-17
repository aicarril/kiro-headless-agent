---
inclusion: auto
---

# Project Context — Agent-Driven Development Pipeline POC

This project demonstrates an automated agent pipeline that replaces traditional CI linting tools
(yamllint, black, pylint) with intelligent agents that can understand context, fix issues, and
enforce consistency across a development team.

## Architecture Overview

### Pipeline Flow
1. Developer pushes code to a feature branch
2. The `ci-review-agent` automatically validates the code against coding standards
3. If issues are found, the agent fixes them and pushes the fixes back to the feature branch
4. Once the code passes review, the `merge-agent` handles merging to main
5. The `production-monitor-agent` watches live AWS metrics and can trigger the pipeline
   if it detects issues that need code changes

### Live AWS Integration
- The `query-optimizer-agent` connects to Athena via AWS CLI to run queries live
- It auto-discovers the slowest queries from workgroup history (no human input needed)
- It applies iterative optimizations: partition pruning → column pruning → JOIN fixes → predicate pushdown
- Critical guardrail: output of optimized query must be identical to original (row-for-row)
- Produces a proof report with before/after metrics, % improvement, and cost savings estimates
- The `log-investigator-agent` scans CloudWatch log groups, ranks errors, and correlates to source code

### MCP Servers Used
- `aws-api` — for Athena queries, CloudWatch metrics, resource discovery
- `slack` (optional) — for notifications on review results and merge status

## Agents

| Agent | Purpose |
|-------|---------|
| `ci-review-agent` | Validates code against standards, replaces yamllint/black/pylint |
| `merge-agent` | Merges approved feature branches to main |
| `production-monitor-agent` | Monitors AWS metrics, generates recommendations, can push fixes |
| `query-optimizer-agent` | Discovers slowest Athena queries, optimizes with output equivalence guardrail |

## Key Directories
- `.kiro/agents/` — Agent definitions
- `.kiro/hooks/` — Automation triggers
- `.kiro/steering/` — Standards and guidelines (auto-included)
- `sample-code/` — Example files for demo purposes
