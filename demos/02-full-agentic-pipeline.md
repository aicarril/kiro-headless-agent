# Demo 2: Full Agentic Development Pipeline

## What This Shows
- Give the agent a task in plain English
- Agent autonomously: clones repo → understands codebase → implements → commits → pushes → creates PR → self-reviews
- Full pipeline runs in a single Docker container
- Output is logged to a timestamped file

## Steps

### 1. Build the Docker image
```bash
docker build --platform linux/amd64 -t kiro-agent:latest .
```

### 2. Run the pipeline with a task
```bash
export KIRO_API_KEY="<your-key>"
export GITHUB_TOKEN="<your-github-pat>"
./run-pipeline.sh "Add a dark mode toggle button that switches between light and dark themes"
```

### 3. Watch the output
The pipeline will show each phase:
```
Phase 1: Clone repo, create branch
Phase 2: Read and understand codebase
Phase 3: Implement the task
Phase 4: Commit and push
Phase 5: Create PR via gh CLI
Phase 6: Self-review the diff
Phase 7: Fix issues if found
Phase 8: Approve + generate report
```

### 4. Check the results
- PR appears at https://github.com/aicarril/amplify-vite-react-template/pulls
- Log file saved as `pipeline-output-YYYYMMDD-HHMMSS.txt`
- Self-review checklist in the output shows what the agent verified

## Example Tasks to Demo
- "Add a footer component with copyright text and current year"
- "Add a navigation bar with Home, About, and Contact links"
- "Create a loading spinner component that shows while data is being fetched"
- "Add a 404 Not Found page with a link back to home"

## What to Point Out During Demo
- The agent reads the codebase FIRST before making changes (Phase 2)
- It follows existing code patterns (function components, separate CSS files)
- The self-review catches real issues (accessibility, layout conflicts)
- The full log is your audit trail — every tool call, every decision
- Total time: ~2 minutes for a complete feature implementation + PR
