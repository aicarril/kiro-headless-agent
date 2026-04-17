#!/bin/bash
# Run the query review agent against a PR.
#
# Usage: ./run-query-review.sh <PR_NUMBER> [REPO]
# Example: ./run-query-review.sh 42
# Example: ./run-query-review.sh 42 aicarril/amplify-vite-react-template
#
# Required env vars:
#   KIRO_API_KEY          - Kiro Pro API key
#   GITHUB_TOKEN          - GitHub PAT with repo scope
#   AWS_ACCESS_KEY_ID     - AWS credentials
#   AWS_SECRET_ACCESS_KEY - AWS credentials

set -e

PR_NUMBER="$1"
REPO="${2:-aicarril/amplify-vite-react-template}"
OUTPUT_FILE="query-review-pr${PR_NUMBER}-$(date +%Y%m%d-%H%M%S).txt"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: ./run-query-review.sh <PR_NUMBER> [REPO]"
  exit 1
fi

if [ -z "$KIRO_API_KEY" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: KIRO_API_KEY, GITHUB_TOKEN, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY must be set"
  exit 1
fi

echo "========================================="
echo "Query Review: $(date)"
echo "PR: #$PR_NUMBER on $REPO"
echo "Output: $OUTPUT_FILE"
echo "========================================="

docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="$KIRO_API_KEY" \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GH_TOKEN="$GITHUB_TOKEN" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_REGION="${AWS_REGION:-us-east-1}" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent query-review-agent \
  "Review PR #$PR_NUMBER on repo $REPO. Find any SQL queries in the diff, run them against live Athena, optimize, validate output equivalence, and post your findings as a PR comment." \
  2>&1 | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\x1b\[?25[hl]//g' | sed 's/\x1b\[0m//g' | tee "$OUTPUT_FILE"

echo ""
echo "========================================="
echo "Done. Output saved to $OUTPUT_FILE"
echo "Check PR #$PR_NUMBER for the review comment."
echo "========================================="
