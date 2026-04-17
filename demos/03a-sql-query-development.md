# Demo 3a: SQL Query Development with Kiro

## What This Shows
- Ask Kiro to write a SQL query from a business requirement
- Kiro writes it, runs it against live Athena, verifies results
- Intentionally writes a non-optimized version first
- Self-optimizes iteratively, showing before/after metrics
- Saves the final query to a file
- You can reference each query execution by ID in the Athena console

## Steps

### 1. Open Kiro chat and give it a requirement

Paste this into Kiro chat:

```
Write me an Athena SQL query that answers this business question:
"Which AWS services had the biggest cost increase from March to April 2026?"

Requirements:
- Query the cost_db.customer_all table
- Compare billing_period '2026-03' vs '2026-04'
- Show the service name, March cost, April cost, and the dollar increase
- Sort by biggest increase first
- Only show services where April cost > March cost

Write the query, run it against Athena to verify it works, then optimize it
for performance. Save the final version to sample-queries/cost_trends.sql.
Show me the Athena query execution IDs so I can verify in the console.
```

### 2. Watch Kiro work
Kiro will:
1. Write an initial query (likely with SELECT * or missing optimizations)
2. Run it via the AWS MCP server (`call_aws` tool)
3. Check the results and execution time
4. Optimize (add partition pruning, column pruning, etc.)
5. Re-run and compare metrics
6. Save the final query to file

### 3. Verify in Athena console
- Go to the Athena console → Query History
- Find the execution IDs Kiro reported
- Compare the runtimes yourself — the optimization is real

## Alternative Prompts to Try

**Top untagged resources by cost:**
```
Write a query to find the top 20 most expensive untagged resources
in my April 2026 CUR data. Run it, optimize it, save to file.
```

**Daily cost anomaly detection:**
```
Write a query that finds days in April 2026 where any service's daily
cost was more than 2x its average daily cost. This is for anomaly detection.
Run it against Athena and optimize.
```

**EC2 right-sizing candidates:**
```
Write a query to find EC2 instance types where the average daily cost
is over $10 but usage amount is low. These are right-sizing candidates.
Run it, verify, optimize, save to sample-queries/rightsizing.sql.
```

## What to Point Out During Demo
- Kiro uses the AWS MCP server to run real queries — not simulating
- The execution IDs are real — you can verify in the Athena console
- The self-optimization loop: first version works but is slow, final version is fast
- The query is saved to a file that can be committed and reviewed by the agents
- This is the workflow: requirement → query → verify → optimize → commit → agent review
