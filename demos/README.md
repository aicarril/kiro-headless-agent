# Demo Playbooks

Step-by-step guides for each demo scenario. Each demo is self-contained and can be run independently.

| # | Demo | What it shows | Time |
|---|------|--------------|------|
| 1 | [GitHub Actions Pipeline](01-github-actions-pipeline.md) | Two agents auto-review every PR, logs visible in Actions tab | 5 min |
| 2 | [Full Agentic Pipeline](02-full-agentic-pipeline.md) | Agent takes a task → writes code → pushes PR → self-reviews | 3 min |
| 3a | [SQL Query Development with Kiro](03a-sql-query-development.md) | Ask Kiro to write a query, run it, self-optimize, save to file | 5 min |
| 3b | [YAML IaC Best Practices](03b-yaml-iac-best-practices.md) | Auto-linting hook, AWS docs MCP, IaC development | 5 min |
| 3c | [Data Pipeline from Scratch](03c-data-pipeline-from-scratch.md) | Ask Kiro to build and deploy a data pipeline to AWS | 10 min |

## Prerequisites

- Docker installed
- Kiro Pro API key (`KIRO_API_KEY`)
- GitHub PAT with repo scope (`GITHUB_TOKEN`)
- AWS credentials configured (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- GitHub secrets configured on the repo (see main README)
