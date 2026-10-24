#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK="brief-c-research-poc"
REGION="us-east-1"
TEMPLATE="$DIR/Brief_C_RDS_EC2_AutoScaling_CloudFormation.yaml"
CHANGE_SET="brief-c-preview-$(date +%Y%m%d%H%M%S)"

echo "Validating template..."
bash "$DIR/validate.sh" >/dev/null

echo "Creating change set: $CHANGE_SET"

aws cloudformation create-change-set \
  --stack-name "$STACK" \
  --change-set-name "$CHANGE_SET" \
  --change-set-type UPDATE \
  --template-body "file://$TEMPLATE" \
  --parameters \
    ParameterKey=LabRoleName,UsePreviousValue=true \
    ParameterKey=AlertEmail,UsePreviousValue=true \
    ParameterKey=LatestAmazonLinuxAmi,UsePreviousValue=true \
    ParameterKey=EnableVpcLambda,UsePreviousValue=true \
  --region "$REGION"

echo
echo "Change set submitted for review."
echo "Open CloudFormation > Stacks > $STACK > Change sets."
echo "Do NOT execute the change set until its changes are reviewed."
echo "Change set name: $CHANGE_SET"

# Wait for change-set creation to finish without executing it.
echo "Checking change-set status..."
if aws cloudformation wait change-set-create-complete \
  --stack-name "$STACK" \
  --change-set-name "$CHANGE_SET" \
  --region "$REGION"; then
  echo "RESULT: CHANGES READY FOR REVIEW"
else
  STATUS=$(aws cloudformation describe-change-set \
    --stack-name "$STACK" \
    --change-set-name "$CHANGE_SET" \
    --region "$REGION" \
    --query Status --output text)
  REASON=$(aws cloudformation describe-change-set \
    --stack-name "$STACK" \
    --change-set-name "$CHANGE_SET" \
    --region "$REGION" \
    --query StatusReason --output text)
  if [[ "$STATUS" == "FAILED" && "$REASON" == *"didn't contain changes"* ]]; then
    echo "RESULT: NO CHANGES — existing infrastructure is unchanged."
  else
    echo "RESULT: ERROR — $STATUS: $REASON" >&2
    exit 1
  fi
fi

echo "SAFETY: Change set has NOT been executed."
