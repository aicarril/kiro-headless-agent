# Kiro Headless Agents in Docker

Autonomous agents that run Kiro CLI in headless mode inside Docker containers.

## Agents

### CI/CD Agents (triggered automatically via GitHub Actions on every PR)

These agents are invoked by `.github/workflows/pr-review.yml` — no manual action needed.

| Agent | What it does | Trigger |
|-------|-------------|---------|
| `pr-reviewer-agent` | Reviews PR diff for bugs, security issues, style violations. Posts findings as a PR comment. | `pull_request` event |
| `query-review-agent` | Finds SQL in the PR diff, runs it against live Athena, optimizes with output equivalence guardrail, posts before/after proof as a PR comment. | `pull_request` event |

After both agents pass, the workflow auto-merges the PR (configurable — remove the `auto-merge` job for human-only approval).

### Standalone Agents (run locally via Docker or in your AWS account)

These agents are invoked manually via `docker run` or the runner scripts. They run anywhere — your laptop, Lambda, ECS, EC2.

| Agent | What it does | Input needed |
|-------|-------------|--------------|
| `pipeline-agent` | Clones repo → implements task → pushes PR → self-reviews → ready for merge | Task description + GitHub token |
| `code-agent` | Implements a single task and pushes a PR (no review) | Task description + GitHub token |
| `query-optimizer-agent` | Discovers slowest Athena queries, optimizes with output equivalence guardrail, produces proof report, and creates a PR with results | AWS creds + GitHub token |
| `log-investigator-agent` | Discovers all CloudWatch log groups, queries for errors, ranks by impact | AWS creds |

## Quick Start

### Build
```bash
docker build --platform linux/amd64 -t kiro-agent:latest .
```

### Log Investigator (autonomous — no input needed)
```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<key>" \
  -e AWS_ACCESS_KEY_ID="<key>" \
  -e AWS_SECRET_ACCESS_KEY="<secret>" \
  -e AWS_REGION="us-east-1" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent log-investigator-agent \
  "Get to work." 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | tee report.txt
```

### Full Pipeline (task → PR → review)
```bash
export KIRO_API_KEY="<key>"
export GITHUB_TOKEN="<github-pat>"
./run-pipeline.sh "Add a footer component with copyright text"
```

### Query Optimizer (autonomous — discovers slow queries itself)
```bash
export KIRO_API_KEY="<key>"
export AWS_ACCESS_KEY_ID="<key>"
export AWS_SECRET_ACCESS_KEY="<secret>"
./run-query-optimizer.sh
```

The optimizer will:
1. Pull query history from Athena and rank by execution time
2. Run the slowest queries live to get a fresh baseline
3. Apply optimizations (partition pruning, column pruning, JOIN fixes, predicate pushdown)
4. Validate that optimized output is identical to the original (guardrail)
5. Produce a proof report with before/after metrics and savings estimates

Output is saved to a timestamped file with ANSI codes stripped for clean logs.

### Pipeline Flow
```
You give a task
    ↓
Pipeline Agent (one container)
    ├── Phase 1: Clone repo, create branch
    ├── Phase 2: Read and understand codebase
    ├── Phase 3: Implement the task
    ├── Phase 4: Commit and push
    ├── Phase 5: Create PR via gh CLI
    ├── Phase 6: Self-review the diff
    ├── Phase 7: Fix issues if found
    └── Phase 8: Approve + generate report
    ↓
PR ready for human merge
```

### PR Review (triggered automatically on every PR via GitHub Actions)
```
Developer opens a PR
    ↓
GitHub Actions triggers two parallel jobs:
    ├── pr-reviewer-agent  → general code review (bugs, security, style)
    └── query-review-agent → finds SQL, runs against live Athena,
                             optimizes, validates output equivalence,
                             posts before/after proof as PR comment
    ↓
Both agents post their findings as PR comments
```

To enable: add `KIRO_API_KEY`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` to your repo's GitHub Secrets (Settings → Secrets → Actions). `GITHUB_TOKEN` is provided automatically by GitHub Actions.

## Credentials

All credentials are passed as environment variables — nothing is hardcoded.

| Env var | Required for | How to get |
|---------|-------------|------------|
| `KIRO_API_KEY` | All agents | https://app.kiro.dev (Pro subscription) |
| `GITHUB_TOKEN` | pipeline-agent, code-agent, pr-reviewer-agent | https://github.com/settings/tokens (repo scope) |
| `GH_TOKEN` | Same as GITHUB_TOKEN (used by gh CLI) | Same token |
| `AWS_ACCESS_KEY_ID` | log-investigator, query-optimizer | AWS IAM or inherited from compute |
| `AWS_SECRET_ACCESS_KEY` | Same | Same |

In production (Lambda/ECS/EC2), AWS credentials are inherited automatically from the IAM role — no env vars needed.

## Project Structure

```
.github/
  workflows/
    pr-review.yml                 # GitHub Actions: triggers both review agents on every PR
.kiro/
  agents/
    log-investigator-agent.json   # CloudWatch error discovery
    pipeline-agent.json           # Full task → PR → review pipeline
    code-agent.json               # Task → PR (no review)
    pr-reviewer-agent.json        # Reviews open PRs
    query-optimizer-agent.json    # Athena query optimization (standalone)
    query-review-agent.json       # SQL review on PRs with live Athena proof
    prompts/                      # Agent instructions (referenced by agents)
  settings/
    mcp.json                      # MCP server config
  steering/
    coding-standards.md           # Auto-included coding standards
    project-context.md            # Auto-included project context
Dockerfile                        # Container: python + aws-cli + gh + kiro-cli
run-pipeline.sh                   # One-command pipeline runner
run-query-optimizer.sh            # One-command query optimizer runner
run-query-review.sh               # One-command query review for a specific PR
sample-queries/
  cost_reports.sql                # CUR cost analysis queries (mix of good and bad)
  event_analytics.sql             # Event/ops dashboard queries (mix of good and bad)
```

## Requirements

- Docker
- Kiro Pro API key
- GitHub PAT with `repo` scope (for PR agents)
- AWS credentials (for CloudWatch/Athena agents)
