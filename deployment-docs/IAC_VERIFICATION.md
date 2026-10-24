# Brief C — Infrastructure as Code Verification

## CloudFormation Resource Inventory
- Template resource definitions: 32
- Deployed CloudFormation resources: 31
- Conditional resource omitted: EmailSubscription
- Reason: AlertEmail is empty, so HasAlertEmail evaluates to false.
- Stack status verified: UPDATE_COMPLETE

## Resource Documentation
- All 32 resource definitions have an immediately preceding comment.
- CloudFormation template validation was performed after the comment update.

## External Resources
- BriefC-Science-S3-Access: manually created IAM policy.
- BriefC-Medicine-S3-Access: manually created IAM policy.
- Other independently deployed project resources have not been exhaustively ruled out.

## IaC Coverage
- Verified CloudFormation-managed resources: 31
- Known independently created project resources: 2
- Provisional coverage: 31 / (31 + 2) = 93.94%
- This is not a final audited percentage because the complete project resource inventory has not been independently reconciled.

## Observability Configuration
- CloudWatch dashboard: 4 metric widgets containing 6 metric entries.
- Three research-processing alarms have SNS alarm actions configured.
- CloudWatch Logs metric filter: PROCESSING_ERROR.
- Email subscription not deployed; notification delivery remains unverified.

## Deployment Safety
- Template validation completed.
- Empty change-set preview returned NO CHANGES before the documentation-only template edit.
- No change set was executed during automation testing.
- No full teardown/redeployment cycle has been performed.
