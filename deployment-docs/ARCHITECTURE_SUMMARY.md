# Brief C — Architecture and Implementation Summary

## 1. Project Objective
Develop a proof-of-concept AWS research data platform supporting separate Science and Medicine research workflows, infrastructure automation, private networking, and operational monitoring within AWS Academy Learner Lab constraints.

## 2. Network Architecture
A VPC with CIDR 10.80.0.0/16 contains two private subnets in different Availability Zones. No NAT gateway or public internet route is configured. An S3 Gateway VPC Endpoint supports private S3 access through endpoint-enabled route tables.

## 3. Research Data Processing
Separate Science and Medicine S3 buckets support research data organisation. S3 EventBridge notifications, SQS messaging, and Lambda processing form an event-driven workflow. Processed CSV outputs are stored in S3. Both Science and Medicine CSV processing paths were tested successfully.

## 4. Database Architecture
Amazon RDS MySQL Community Edition is deployed privately on db.t3.micro with encrypted storage, seven-day backup retention, and master credentials managed by Secrets Manager. Application-to-database connectivity has not yet been tested.

## 5. Compute and Scalability
An EC2 Auto Scaling Group uses Amazon Linux 2023 and t3.micro instances. Its configured minimum, desired, and maximum capacities are 0, 1, and 2 respectively, with CPU target tracking at 60%. One instance was verified healthy. Actual scale-out behaviour and application deployment remain untested.

## 6. Monitoring
CloudWatch dashboards and alarms provide monitoring configuration, while SNS supports notification workflows. Successful alarm triggering and notification delivery have not been independently verified.

## 7. Security
The architecture uses private subnet placement, an S3 VPC endpoint, RDS encryption, Secrets Manager, and IAM policies. Two faculty-oriented S3 access policies were created, but faculty-specific access enforcement is incomplete because AWS Academy permissions prevented IAM group creation.

## 8. Infrastructure as Code
AWS CloudFormation manages the deployed stack brief-c-research-poc in us-east-1. The validate.sh script validates the template. The preview.sh script creates an UPDATE change set and reports its status without automatically executing changes. Manual review and explicit approval are required before deployment.

## 9. Architectural Trade-offs
- Private subnets improve network isolation but constrain outbound connectivity.
- The S3 Gateway VPC Endpoint provides private S3 connectivity without a NAT gateway, but it does not provide connectivity to every AWS service.
- Small instance types limit cost but also constrain processing and database capacity.
- Event-driven processing reduces the need for continuously running processing servers.
- Manual change-set approval prioritises deployment safety over fully automated continuous delivery.
- AWS Academy IAM restrictions prevent full implementation of some planned access-management controls.

## 10. Implementation Status
Successfully demonstrated: CloudFormation validation, safe no-change preview, deployed-stack health, Science and Medicine CSV processing, and one healthy EC2 instance.

Not yet verified: application-to-RDS connectivity, actual Auto Scaling scale-out, faculty IAM enforcement, disaster-recovery restoration, and alarm notification delivery.

## 11. Conclusion
The proof of concept demonstrates a deployed AWS research infrastructure with modular services, private networking, event-driven processing, and controlled CloudFormation update automation. Further validation and access-control work would be necessary before production use.
