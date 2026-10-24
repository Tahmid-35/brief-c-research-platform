#!/usr/bin/env bash
set -euo pipefail

STACK="brief-c-research-poc"
REGION="us-east-1"

if [[ $# -ne 1 ]]; then
  echo "Usage: bash check-preview.sh CHANGE_SET_NAME"
  exit 2
fi

CHANGE_SET="$1"

aws cloudformation describe-change-set \
  --stack-name "$STACK" \
  --change-set-name "$CHANGE_SET" \
  --region "$REGION" \
  --query '{Status:Status,Reason:StatusReason,Changes:Changes[*].{Action:ResourceChange.Action,Resource:ResourceChange.LogicalResourceId,Replacement:ResourceChange.Replacement}}' \
  --output json
