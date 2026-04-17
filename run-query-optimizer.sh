#!/bin/bash
# Run the query optimizer agent.
#
# Usage: ./run-query-optimizer.sh
#
# Required env vars:
#   KIRO_API_KEY          - Kiro Pro API key
#   AWS_ACCESS_KEY_ID     - AWS credentials
#   AWS_SECRET_ACCESS_KEY - AWS credentials
#   GITHUB_TOKEN          - GitHub PAT with repo scope
#   AWS_REGION            - (optional, defaults to us-east-1)

set -e

OUTPUT_FILE="query-optimizer-report-$(date +%Y%m%d-%H%M%S).txt"

if [ -z "$KIRO_API_KEY" ]; then
  echo "Error: KIRO_API_KEY must be set"
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN must be set"
  exit 1
fi

echo "========================================="
echo "Query Optimizer: $(date)"
echo "Output: $OUTPUT_FILE"
echo "========================================="

docker run --rm --platform linux/amd64 \
  -e KIRO_API_KEY="$KIRO_API_KEY" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_REGION="${AWS_REGION:-us-east-1}" \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GH_TOKEN="$GITHUB_TOKEN" \
  kiro-agent:latest \
  chat --no-interactive --trust-all-tools --agent query-optimizer-agent \
  "Discover the slowest queries in the Athena workgroup, optimize them, validate output equivalence, produce a proof report, and create a PR with the results." \
  2>&1 | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\x1b\[?25[hl]//g' | sed 's/\x1b\[0m//g' | tee "$OUTPUT_FILE"

echo ""
echo "========================================="
echo "Done. Report saved to $OUTPUT_FILE"
echo "========================================="
