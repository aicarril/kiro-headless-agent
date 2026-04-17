#!/bin/bash
# Run the full pipeline in one container.
#
# Usage: ./run-pipeline.sh "<task description>"
# Example: ./run-pipeline.sh "Add a footer component with copyright text"
#
# Required env vars:
#   KIRO_API_KEY    - Kiro Pro API key
#   GITHUB_TOKEN    - GitHub PAT with repo scope

set -e

TASK="$1"
REPO="aicarril/amplify-vite-react-template"

if [ -z "$TASK" ]; then
  echo "Usage: ./run-pipeline.sh \"<task description>\""
  exit 1
fi

if [ -z "$KIRO_API_KEY" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: KIRO_API_KEY and GITHUB_TOKEN must be set"
  exit 1
fi

echo "========================================="
echo "Pipeline: $(date)"
echo "Task: $TASK"
echo "Repo: $REPO"
echo "========================================="

docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="$KIRO_API_KEY" \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GH_TOKEN="$GITHUB_TOKEN" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent pipeline-agent \
  "Task: $TASK. Repo: https://github.com/$REPO" \
  2>&1 | tee pipeline-output.txt

echo ""
echo "========================================="
echo "Done. Output saved to pipeline-output.txt"
echo "Check https://github.com/$REPO/pulls for the PR."
echo "========================================="
