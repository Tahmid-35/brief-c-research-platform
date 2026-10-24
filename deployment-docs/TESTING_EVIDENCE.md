# Brief C — Infrastructure Testing and Evidence

## 1. Verified Tests
| Component | Test performed | Result |
|---|---|---|
| CloudFormation | Template validation | PASS |
| CloudFormation | Stack status verification | PASS — UPDATE_COMPLETE |
| CloudFormation | Empty change-set detection | PASS — NO CHANGES |
| S3/Lambda processing | Science CSV processing | PASS |
| S3/Lambda processing | Medicine CSV processing | PASS |
| EC2 Auto Scaling | One instance health verification | PASS |

## 2. Configured but Not Fully Tested
| Component | Current status | Remaining verification |
|---|---|---|
| RDS MySQL | Deployed privately | Application connectivity |
| EC2 Auto Scaling | Configured | Actual scale-out behaviour |
| EC2 application | Not deployed | Application installation and testing |
| IAM faculty isolation | Policies created | Faculty-specific enforcement |
| Disaster recovery | Backup settings configured | Restore and recovery testing |
| Monitoring | Dashboard and alarms configured | Alarm triggering and notification delivery |

## 3. Automation Evidence
- validate.sh successfully validated the CloudFormation template.
- preview.sh created an UPDATE change set without executing it.
- Empty change sets were recognised as NO CHANGES.
- The deployed stack remained UPDATE_COMPLETE after testing.
- Automated execution was intentionally excluded to protect existing resources.

## 4. AWS Academy Restrictions
- IAM group creation was denied by Learner Lab permissions.
- Two S3 managed IAM policies were created.
- Faculty-specific access enforcement remains incomplete.
- CodePipeline was explored but not implemented due to service-role limitations.

## 5. Evidence Checklist
Capture screenshots of:
- CloudFormation stack status and resource list
- Successful template validation
- Preview script showing NO CHANGES
- Science CSV processing results
- Medicine CSV processing results
- Healthy EC2 instance
- Private RDS configuration and backup settings
- CloudWatch dashboard and configured alarms
- IAM policies and relevant permissions error, if available

## 6. Evidence Integrity
Use only screenshots and outputs from actual AWS tests. Do not present configured services as fully tested or claim unimplemented CI/CD, IAM enforcement, database connectivity, or Auto Scaling scale-out.
