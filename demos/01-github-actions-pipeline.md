# Demo 1: GitHub Actions Pipeline

## What This Shows
- Two agents automatically review every PR in parallel
- `pr-reviewer-agent`: general code review (bugs, security, style)
- `query-review-agent`: finds SQL, runs against live Athena, optimizes, posts proof
- Logs are visible in the GitHub Actions tab
- PR comments show the agent's findings

## Prerequisites
- GitHub secrets configured: `KIRO_API_KEY`, `GH_PAT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- Workflow file `.github/workflows/pr-review.yml` pushed to main

## Steps

### 1. Create a feature branch with a bad SQL query
```bash
git checkout -b feature/demo-bad-query
```

### 2. Add an intentionally unoptimized query
Add this to `sample-queries/cost_reports.sql`:
```sql
-- Q9: Service cost with resource details (intentionally bad)
SELECT *
FROM cost_db.customer_all
WHERE line_item_unblended_cost > 0
ORDER BY line_item_unblended_cost DESC
LIMIT 50;
```
This query has no partition filter and uses SELECT * — the agents will catch both.

### 3. Commit and push
```bash
git add sample-queries/cost_reports.sql
git commit -m "[queries] Add service cost resource detail query"
git push origin feature/demo-bad-query
```

### 4. Open a PR
```bash
gh pr create --title "Add service cost query" --body "New query for resource-level cost analysis" --base main
```

### 5. Watch the agents work
- Go to the repo's **Actions** tab to see both jobs running in parallel
- Click into each job to see the agent's live logs (tool calls, reasoning, results)
- After completion, check the **PR conversation** for two comments:
  - Code review agent: general feedback
  - Query review agent: before/after Athena metrics with proof

## What to Point Out During Demo
- Both agents run in parallel — no sequential bottleneck
- The query review agent actually RUNS the query against live Athena (show the execution time)
- The output equivalence check — optimized query returns identical results
- The cost savings estimate in the PR comment
- All logs are in the Actions tab — full transparency of what the agent did
