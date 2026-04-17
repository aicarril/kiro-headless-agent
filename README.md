# Kiro Headless Agent in Docker

An autonomous agent that runs Kiro CLI in headless mode inside a Docker container. It discovers CloudWatch log groups, queries them for errors, ranks issues by impact, and can correlate errors to source code and push fixes.

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
5. If a GitHub repo is provided, clones it and correlates errors to source code
6. Generates a report with findings and recommended fixes

## Agents

| Agent | Description |
|-------|-------------|
| `log-investigator-agent` | Autonomous error investigator — discovers logs, ranks errors, recommends fixes |
| `query-optimizer-agent` | Runs Athena queries live and iterates until target latency is met |

## Project Structure

```
.kiro/
  agents/
    log-investigator-agent.json   # Agent definition
    query-optimizer-agent.json    # Agent definition
    prompts/
      log-investigator.md         # Agent instructions
      query-optimizer.md          # Agent instructions
  settings/
    mcp.json                      # MCP server config
  steering/
    coding-standards.md           # Auto-included standards
    project-context.md            # Auto-included context
Dockerfile                        # Container definition
```

## Requirements

- Docker
- Kiro Pro API key (for headless mode)
- AWS credentials with CloudWatch Logs read access
