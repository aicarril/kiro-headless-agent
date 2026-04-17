#!/bin/bash
# Pipeline: Code Agent → PR Reviewer → (loop if rejected) → Human merges
#
# Usage: ./run-pipeline.sh "<task description>"
# Example: ./run-pipeline.sh "Add a dark mode toggle to the settings page"
#
# Required env vars:
#   KIRO_API_KEY    - Kiro Pro API key
#   GITHUB_TOKEN    - GitHub PAT with repo + PR permissions
#   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY - (optional, for log investigator)

set -e

TASK="$1"
REPO="aicarril/amplify-vite-react-template"
MEMORY_DIR="$(pwd)/pipeline-output"
MAX_RETRIES=2

if [ -z "$TASK" ]; then
  echo "Usage: ./run-pipeline.sh \"<task description>\""
  exit 1
fi

if [ -z "$KIRO_API_KEY" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: KIRO_API_KEY and GITHUB_TOKEN must be set"
  exit 1
fi

mkdir -p "$MEMORY_DIR"

echo "========================================="
echo "Pipeline Start: $(date)"
echo "Task: $TASK"
echo "Repo: $REPO"
echo "Output: $MEMORY_DIR/"
echo "========================================="

# --- Step 1: Code Agent ---
echo ""
echo ">>> Step 1: Code Agent — implementing task..."
echo ""

docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="$KIRO_API_KEY" \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GH_TOKEN="$GITHUB_TOKEN" \
  -v "$MEMORY_DIR:/output" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent code-agent \
  "Task: $TASK. Repo: https://github.com/$REPO. After you finish, write a summary of what you did to /output/code-agent-report.md" \
  2>&1 | tee "$MEMORY_DIR/code-agent-log.txt"

echo ""
echo ">>> Code Agent done. Output saved to $MEMORY_DIR/code-agent-log.txt"

# --- Step 2: PR Reviewer ---
RETRY=0
APPROVED=false

while [ "$RETRY" -lt "$MAX_RETRIES" ] && [ "$APPROVED" = "false" ]; do
  RETRY=$((RETRY + 1))
  echo ""
  echo ">>> Step 2: PR Reviewer (attempt $RETRY/$MAX_RETRIES)..."
  echo ""

  docker run --rm --platform linux/amd64 \
    -e KIRO_API_KEY="$KIRO_API_KEY" \
    -e GITHUB_TOKEN="$GITHUB_TOKEN" \
    -e GH_TOKEN="$GITHUB_TOKEN" \
    -v "$MEMORY_DIR:/output" \
    kiro-agent:latest \
    chat --no-interactive --trust-all-tools --agent pr-reviewer-agent \
    "Review all open PRs on https://github.com/$REPO. Write your review results to /output/review-report.md. If you approve, write APPROVED on the first line. If you request changes, write CHANGES_REQUESTED on the first line followed by what needs fixing." \
    2>&1 | tee "$MEMORY_DIR/pr-reviewer-log-$RETRY.txt"

  # Check if approved
  if [ -f "$MEMORY_DIR/review-report.md" ]; then
    FIRST_LINE=$(head -1 "$MEMORY_DIR/review-report.md" 2>/dev/null || echo "")
    if echo "$FIRST_LINE" | grep -qi "APPROVED"; then
      APPROVED=true
      echo ""
      echo ">>> PR APPROVED by reviewer agent!"
    fi
  fi

  if [ "$APPROVED" = "false" ] && [ "$RETRY" -lt "$MAX_RETRIES" ]; then
    echo ""
    echo ">>> PR rejected. Sending back to code agent to fix..."
    echo ""

    FEEDBACK=$(cat "$MEMORY_DIR/review-report.md" 2>/dev/null || echo "Review feedback not available")

    docker run --rm --platform linux/amd64 \
      -e KIRO_API_KEY="$KIRO_API_KEY" \
      -e GITHUB_TOKEN="$GITHUB_TOKEN" \
      -e GH_TOKEN="$GITHUB_TOKEN" \
      -v "$MEMORY_DIR:/output" \
      kiro-agent:latest \
      chat --no-interactive --trust-all-tools --agent code-agent \
      "The PR reviewer rejected your changes. Fix the issues and push again. Repo: https://github.com/$REPO. Reviewer feedback: $FEEDBACK. Write updated summary to /output/code-agent-report.md" \
      2>&1 | tee "$MEMORY_DIR/code-agent-fix-log-$RETRY.txt"
  fi
done

# --- Final Report ---
echo ""
echo "========================================="
echo "Pipeline Complete: $(date)"
echo "========================================="
echo "Task: $TASK"
echo "Approved: $APPROVED"
echo ""
echo "Output files:"
ls -la "$MEMORY_DIR/"
echo ""
if [ "$APPROVED" = "true" ]; then
  echo ">>> PR is approved and ready for human merge."
  echo ">>> Go to https://github.com/$REPO/pulls to merge."
else
  echo ">>> PR was not approved after $MAX_RETRIES attempts."
  echo ">>> Check $MEMORY_DIR/ for logs and review feedback."
fi
