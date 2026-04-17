# Kiro Headless Agents in Docker

Autonomous agents that run Kiro CLI in headless mode inside Docker containers.

## Agents

| Agent | What it does | Input needed |
|-------|-------------|--------------|
| `log-investigator-agent` | Discovers all CloudWatch log groups, queries for errors, ranks by impact | Just AWS creds |
| `pipeline-agent` | Clones repo → implements task → pushes PR → self-reviews → ready for human merge | Task description + GitHub token |
| `pr-reviewer-agent` | Reviews all open PRs on a repo, approves or requests changes | GitHub token |
| `code-agent` | Implements a single task and pushes a PR (no review) | Task description + GitHub token |
| `query-optimizer-agent` | Runs Athena queries live, iterates until target latency is met | AWS creds |

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
.kiro/
  agents/
    log-investigator-agent.json   # CloudWatch error discovery
    pipeline-agent.json           # Full task → PR → review pipeline
    code-agent.json               # Task → PR (no review)
    pr-reviewer-agent.json        # Reviews open PRs
    query-optimizer-agent.json    # Athena query optimization
    prompts/                      # Agent instructions (referenced by agents)
  settings/
    mcp.json                      # MCP server config
  steering/
    coding-standards.md           # Auto-included coding standards
    project-context.md            # Auto-included project context
Dockerfile                        # Container: python + aws-cli + gh + kiro-cli
run-pipeline.sh                   # One-command pipeline runner
```

## Requirements

- Docker
- Kiro Pro API key
- GitHub PAT with `repo` scope (for PR agents)
- AWS credentials (for CloudWatch/Athena agents)
