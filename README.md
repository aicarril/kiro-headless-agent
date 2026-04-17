# Kiro Headless Agents in Docker

Autonomous agents that run Kiro CLI in headless mode inside Docker containers. Three agents, one pipeline:

1. **Log Investigator** — discovers CloudWatch log groups, queries for errors, ranks by impact
2. **Code Agent** — accepts a task, clones a repo, implements the change, pushes a PR
3. **PR Reviewer** — reviews open PRs, approves or requests changes (never merges — that's human only)

The pipeline script chains them: Code Agent → PR Reviewer → (fix loop if rejected) → human merges.

## Quick Start

### Build
```bash
docker build --platform linux/amd64 -t kiro-agent:latest .
```

### Run Individual Agents

**Log Investigator** (no input needed — discovers errors autonomously):
```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<key>" \
  -e AWS_ACCESS_KEY_ID="<key>" \
  -e AWS_SECRET_ACCESS_KEY="<secret>" \
  -e AWS_REGION="us-east-1" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent log-investigator-agent \
  "Get to work." 2>&1 | tee report.txt
```

**Code Agent** (give it a task and a repo):
```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<key>" \
  -e GITHUB_TOKEN="<github-pat>" \
  -e GH_TOKEN="<github-pat>" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent code-agent \
  "Task: Add a footer component. Repo: https://github.com/aicarril/amplify-vite-react-template"
```

**PR Reviewer** (reviews open PRs on a repo):
```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<key>" \
  -e GITHUB_TOKEN="<github-pat>" \
  -e GH_TOKEN="<github-pat>" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent pr-reviewer-agent \
  "Review all open PRs on https://github.com/aicarril/amplify-vite-react-template"
```

### Run the Full Pipeline

The pipeline script chains Code Agent → PR Reviewer with a retry loop:

```bash
export KIRO_API_KEY="<key>"
export GITHUB_TOKEN="<github-pat>"
./run-pipeline.sh "Add a dark mode toggle to the settings page"
```

Pipeline flow:
1. Code Agent clones repo, implements task, pushes PR
2. PR Reviewer checks the PR
3. If rejected → Code Agent fixes based on feedback → PR Reviewer re-reviews
4. If approved → human merges

All logs and reports are saved to `pipeline-output/`.

## Memory Between Agents

Agents share context via a mounted volume (`pipeline-output/`). Each agent writes its report there, and the next agent reads it. The orchestrator script passes reviewer feedback back to the code agent when changes are requested.

## Requirements

- Docker
- Kiro Pro API key (headless mode)
- GitHub Personal Access Token (for code agent and PR reviewer)
- AWS credentials (only for log investigator)

### GitHub Token Scopes
The GitHub PAT needs: `repo`, `read:org` (for PR creation and review).
