#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

FUNCTION="brief-c-research-poc-research-processor"
REGION="us-east-1"
BACKUP="deployment-backups/research-processor-original.zip"

if [[ ! -f "$BACKUP" ]]; then
  echo "ERROR: Original Lambda backup not found."
  exit 1
fi

python3 - "$BACKUP" <<'PY'
import sys
from zipfile import ZipFile
with ZipFile(sys.argv[1]) as z:
    assert z.testzip() is None, 'Backup ZIP is corrupted'
    assert 'index.py' in z.namelist(), 'Lambda handler missing'
print('Original Lambda backup validated')
PY

STATE=$(aws lambda get-function-configuration --function-name "$FUNCTION" --region "$REGION" --query State --output text)
UPDATE=$(aws lambda get-function-configuration --function-name "$FUNCTION" --region "$REGION" --query LastUpdateStatus --output text)

if [[ "$STATE" != "Active" || "$UPDATE" != "Successful" ]]; then
  echo "ERROR: Lambda is not ready for rollback."
  exit 1
fi

echo "TARGET: $FUNCTION"
echo "BACKUP: $BACKUP"
echo "WARNING: This will replace the currently deployed Lambda code."
read -r -p 'Type ROLLBACK to continue: ' CONFIRM

if [[ "$CONFIRM" != "ROLLBACK" ]]; then
  echo "Rollback cancelled."
  exit 0
fi

aws lambda update-function-code \
  --function-name "$FUNCTION" \
  --region "$REGION" \
  --zip-file "fileb://$BACKUP" \
  --output json >/dev/null

aws lambda wait function-updated \
  --function-name "$FUNCTION" \
  --region "$REGION"

echo "ROLLBACK COMPLETED — verify application functionality."
