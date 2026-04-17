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
- The `query-optimizer-agent` connects to Athena via the AWS MCP server to run queries live
- It iterates on query optimization until performance targets are met (< 50ms)
- The `production-monitor-agent` pulls CloudWatch metrics and cost data for recommendations

### MCP Servers Used
- `aws-api` — for Athena queries, CloudWatch metrics, resource discovery
- `slack` (optional) — for notifications on review results and merge status

## Agents

| Agent | Purpose |
|-------|---------|
| `ci-review-agent` | Validates code against standards, replaces yamllint/black/pylint |
| `merge-agent` | Merges approved feature branches to main |
| `production-monitor-agent` | Monitors AWS metrics, generates recommendations, can push fixes |
| `query-optimizer-agent` | Runs Athena queries, iterates until < 50ms target is achieved |

## Key Directories
- `.kiro/agents/` — Agent definitions
- `.kiro/hooks/` — Automation triggers
- `.kiro/steering/` — Standards and guidelines (auto-included)
- `sample-code/` — Example files for demo purposes
