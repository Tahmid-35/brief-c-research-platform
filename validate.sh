#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/Brief_C_RDS_EC2_AutoScaling_CloudFormation.yaml"

echo "Validating Brief C CloudFormation template..."

aws cloudformation validate-template \
  --template-body "file://$TEMPLATE" \
  --region "$REGION"

echo "SUCCESS: CloudFormation template validation passed."
