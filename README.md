# Brief C — University Research Data Platform

## 1. Project Overview
This AWS Academy Cloud Architecture proof of concept provides private cloud infrastructure for university research data processing, with separate Science and Medicine S3 storage and automated event-driven CSV processing.

The project focuses on infrastructure deployment, automation, monitoring, security controls, and cost-conscious design within AWS Academy Learner Lab restrictions.

## 2. AWS Environment
- Region: us-east-1 (N. Virginia)
- CloudFormation stack: brief-c-research-poc
- Deployment method: AWS CloudFormation and AWS CLI scripts
- IAM execution environment: AWS Academy Learner Lab with LabRole
- CI/CD: Not implemented; change-set previews provide controlled IaC updates

## 3. Architecture
### Networking
- Private VPC: 10.80.0.0/16
- Two private subnets across different Availability Zones
- No NAT gateway or public internet route
- S3 Gateway VPC Endpoint

### Research Data Processing
- Separate Science and Medicine S3 buckets
- S3 EventBridge notifications
- Event routing to SQS and dead-letter queue
- Lambda research data processing
- Processed output stored in S3

### Database
- Amazon RDS MySQL Community Edition
- DB identifier: brief-c-research-poc-research-db
- Instance type: db.t3.micro
- Private network access
- Encrypted storage and seven-day backups
- Master credentials managed using AWS Secrets Manager

### Compute
- Amazon Linux 2023 EC2 instances
- EC2 Auto Scaling Group: minimum 0, desired 1, maximum 2
- CPU target tracking: 60%
- Instance type: t3.micro
- No research application deployed on EC2 yet

### Monitoring
- CloudWatch dashboard and alarms
- SNS notifications configured

## 4. Infrastructure as Code
Main template:

    Brief_C_RDS_EC2_AutoScaling_CloudFormation.yaml

Supporting files:

    deployed-parameters.json
    validate.sh
    preview.sh
    check-preview.sh

The deployed CloudFormation parameter EnableVpcLambda=true must be preserved during updates, even though the template default is false.

## 5. Validation
From the project directory, run:

    bash validate.sh

This validates the CloudFormation template without deploying infrastructure.

## 6. Preview Infrastructure Changes
Run:

    bash preview.sh

The script validates the template, creates an UPDATE change set, and checks the result.

Possible results:
- NO CHANGES: no proposed infrastructure changes
- CHANGES READY FOR REVIEW: inspect the exact change set before execution
- ERROR: investigate before proceeding

The script does not automatically execute change sets.

## 7. Safe Deployment and Updates
See:

    deployment-docs/SAFE_DEPLOYMENT.md

All proposed resource additions, modifications, replacements, and deletions must be reviewed before manual approval and execution.

Special protection is required for existing RDS databases, S3 buckets, and networking resources.

## 8. Verified Testing
- CloudFormation template validation: passed
- CloudFormation stack status: UPDATE_COMPLETE
- No-change change-set detection: passed
- Science CSV processing: tested successfully
- Medicine CSV processing: tested successfully
- EC2 Auto Scaling Group: one instance verified healthy

## 9. Not Yet Verified
- RDS application connectivity
- Actual Auto Scaling scale-out behaviour
- Faculty-specific IAM access enforcement
- EC2 research application deployment
- End-to-end disaster recovery

These features must not be reported as successfully tested.

## 10. AWS Academy Limitations
- IAM group creation was blocked by permission restrictions.
- Two S3 IAM policies were created, but faculty-specific enforcement remains incomplete.
- No suitable existing CodePipeline service role was available.
- Full CI/CD was not implemented.
- Learner Lab budget and permission restrictions limit production-style features.

## 11. Troubleshooting
### Empty change set
CloudFormation may report FAILED when a change set contains no changes. This does not mean the deployed stack has failed. Check the StatusReason and stack status.

### CloudFormation update failure
Inspect stack events, proposed resource changes, IAM permissions, and rollback status. Do not assume application data will be restored by infrastructure rollback.

### Private connectivity
Verify subnet routing, security groups, VPC endpoints, and service permissions before attempting network changes.

### IAM AccessDenied
Check Learner Lab restrictions. Do not attempt to bypass administrator-enforced permissions.

## 12. Security and Cost Considerations
- Private network placement reduces direct internet exposure.
- S3 endpoint supports private access to S3 from the VPC.
- RDS encryption and Secrets Manager support data protection.
- Auto Scaling supports adjustable compute capacity.
- Resource usage and costs must be monitored within the AWS Academy lab budget.

## 13. Evidence and Demonstration
Capture evidence of CloudFormation deployment, template validation, change-set preview, successful CSV processing, EC2 health, RDS configuration, and monitoring.

Distinguish observed test results from configured-but-untested functionality.

## 14. Project Status
Infrastructure proof of concept deployed. CloudFormation validation and safe preview automation tested. Documentation and remaining verification activities are in progress.

## 15. Safe Teardown and Resource Cleanup

This project contains stateful resources, including an RDS database and S3 research data buckets. Teardown must be explicitly authorised and must not be performed simply to finish a lab session.

### Prerequisites
1. Obtain approval from the project team before deleting the CloudFormation stack.
2. Confirm that research data and any required evidence have been exported to approved storage.
3. Review RDS backup and recovery requirements and verify whether a final snapshot is necessary.
4. Review CloudFormation DeletionPolicy and UpdateReplacePolicy settings for every stateful resource.
5. Identify manually created resources, including the two faculty-specific IAM policies, which CloudFormation will not remove.
6. Review potential charges for retained snapshots, S3 objects, and other resources.

### Teardown Procedure
1. In AWS Console, open CloudFormation in us-east-1.
2. Select the stack named brief-c-research-poc.
3. Inspect its resources, dependencies, and retention policies.
4. Confirm that data protection and recovery requirements are satisfied.
5. Only after explicit approval, use the CloudFormation console's Delete action.
6. Monitor stack events and investigate DELETE_FAILED or retained resources.
7. Verify which resources were removed and which remain, including retained snapshots and external IAM policies.
8. Remove retained resources separately only when authorised and no longer required.

### Important Warnings
- Do not run teardown against the active proof of concept without explicit approval.
- CloudFormation deletion can permanently remove resources and data that are not protected by appropriate retention settings.
- RDS snapshot policies do not replace tested backup and recovery procedures.
- Manually created IAM policies are outside CloudFormation lifecycle management.
- Teardown and full redeployment have not been performed or verified for this project.
