# Kiro Headless Agent in Docker

An autonomous agent that runs Kiro CLI in headless mode inside a Docker container. It discovers CloudWatch log groups, queries them for errors, and ranks issues by impact.

Runs anywhere: Lambda, ECS, EKS, EC2, or your local Docker Desktop.

## Quick Start

### Build
```bash
docker build --platform linux/amd64 -t kiro-agent:latest .
```

### Run
```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<your-kiro-api-key>" \
  -e AWS_ACCESS_KEY_ID="<key>" \
  -e AWS_SECRET_ACCESS_KEY="<secret>" \
  -e AWS_REGION="us-east-1" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent log-investigator-agent \
  "Get to work." 2>&1 | tee report.txt
```

## What It Does

1. Discovers all CloudWatch log groups in the account
2. Filters to application-relevant logs (skips CDK/infra plumbing)
3. Queries each log group for errors in the last 24 hours
4. Ranks errors by frequency, severity, and impact
5. Generates a report with findings and recommended fixes

## Extending: Code Correlation and PRs

The agent can also clone a GitHub repo, correlate errors to source code, and push a fix — but this requires providing a repo in the prompt:

```bash
docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="<key>" \
  -e AWS_ACCESS_KEY_ID="<key>" \
  -e AWS_SECRET_ACCESS_KEY="<secret>" \
  -e AWS_REGION="us-east-1" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent log-investigator-agent \
  "Get to work. If you find errors, clone https://github.com/<owner>/<repo> and correlate errors to source code. Push a fix if possible."
```

For private repos, mount a git credential or SSH key into the container.

## Agents

| Agent | Description |
|-------|-------------|
| `log-investigator-agent` | Autonomous error investigator — discovers logs, ranks errors, recommends fixes |
| `query-optimizer-agent` | Runs Athena queries live and iterates until target latency is met |

## Project Structure

```
.kiro/
  agents/
    log-investigator-agent.json
    query-optimizer-agent.json
    prompts/
      log-investigator.md
      query-optimizer.md
  settings/
    mcp.json
  steering/
    coding-standards.md
    project-context.md
Dockerfile
```

## Requirements

- Docker
- Kiro Pro API key (for headless mode)
- AWS credentials with CloudWatch Logs read access
