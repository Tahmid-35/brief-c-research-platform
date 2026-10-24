#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
FUNCTION="brief-c-research-poc-research-processor"
PACKAGE="app/research-processor.zip"

cd "$(dirname "$0")"

echo "Checking Lambda deployment readiness..."

aws lambda get-function-configuration \
  --function-name "$FUNCTION" \
  --region "$REGION" \
  --query '{State:State,LastUpdateStatus:LastUpdateStatus,Runtime:Runtime,Handler:Handler}' \
  --output json

python3 -m unittest discover -s tests -v

python3 - <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

source = Path('app/index.py')
package = Path('app/research-processor.zip')
assert source.is_file(), 'Application source not found'

with ZipFile(package, 'w', ZIP_DEFLATED) as archive:
    archive.write(source, arcname='index.py')

with ZipFile(package) as archive:
    assert archive.namelist() == ['index.py']
    assert archive.read('index.py') == source.read_bytes()

print('Deployment package verified:', package)
PY

echo "PRE-DEPLOYMENT CHECKS COMPLETED"
echo "No Lambda update has been performed."
