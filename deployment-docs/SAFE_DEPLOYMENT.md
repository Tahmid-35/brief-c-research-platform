# Brief C — Safe CloudFormation Deployment Procedure

## Environment
- Region: us-east-1
- Stack: brief-c-research-poc
- Platform: AWS Academy Learner Lab
- Infrastructure: Private VPC, S3, Lambda, SQS, RDS MySQL, EC2 Auto Scaling, CloudWatch and SNS.

## 1. Pre-deployment checks
1. Confirm the stack is in a stable state, normally UPDATE_COMPLETE.
2. Confirm the CloudFormation template is validated.
3. Check the current stack parameters, especially EnableVpcLambda=true.
4. Protect existing research data and review the RDS backup and recovery position.

## 2. Create a change set
Run:

    bash ~/brief-c-automation/preview.sh

The script creates an UPDATE change set but does not execute it.

## 3. Review proposed changes
In AWS Console, open CloudFormation > Stacks > brief-c-research-poc > Change sets.

Review every resource change, including:
- Additions
- Modifications
- Replacements
- Deletions

Pay special attention to RDS, S3, VPC networking, Lambda permissions, and EC2 Auto Scaling resources.

A proposed replacement or deletion of an RDS database or S3 bucket must not be approved without a separate data-protection and recovery review.

CloudFormation change-set previews may not capture every indirect or runtime consequence of an update. Review the template differences and relevant AWS documentation as well.

## 4. Approval and execution
No change set may be executed automatically.

Only after explicit approval of the exact change-set name and its full proposed changes may an authorised operator execute it manually in CloudFormation.

If the review is not satisfactory, do not execute the change set.

## 5. Post-deployment verification
- Check CloudFormation stack status.
- Review stack events and CloudWatch alarms.
- Verify critical application and data-processing functions.
- Confirm RDS availability and relevant backup settings.
- Collect evidence of actual tests performed.

## 6. Failure and rollback
CloudFormation may attempt automatic rollback after a failed update, depending on the update configuration. Do not assume rollback restores application data.

Inspect stack events and resource states before taking corrective action. Confirm database recovery options before any potentially destructive operation.

## 7. Known limitations
- AWS Academy restricts IAM actions, including IAM group creation.
- CodePipeline CI/CD was not implemented.
- AWS CLI and CloudFormation scripts provide controlled deployment automation.
- RDS application connectivity, EC2 scale-out behaviour, and faculty-specific IAM enforcement have not been fully tested.
