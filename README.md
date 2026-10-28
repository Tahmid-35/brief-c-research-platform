# Brief C — University Research Data Platform

## Project overview

This repository holds our AWS CloudFormation infrastructure template and instructions on how to deploy it to create a Brief C: University Research Data Platform infrastructure. We created a working proof of concept (PoC) on AWS Academy Learner Lab, US East (N. Virginia), `us-east-1`. The tested stack is called: brief-c-research-poc.

The PoC includes research file uploads, asynchronous processing, research file monitoring and infrastructure management. The client has larger production requirements: 500 researchers at 12 faculties, datasets from 10 Gb to 50 Tb, good faculty isolation and various types of computing. The lab implementation is for basic processing pattern validation and not for production scale.

## What the template deploys


| Component | Purpose / Key Configuration |
|---|---|
| **Amazon VPC** | VPC CIDR `10.80.0.0/16`, with two private subnets across two Availability Zones, a private route table, and an S3 gateway endpoint. The private route table has no default route to the internet. |
| **Amazon S3** | Separate input buckets for Science and Medicine, plus a shared output bucket for processed results. S3 encryption is enabled, and public access is blocked. |
| **Amazon EventBridge** | Routes S3 object-created events from the faculty input buckets to the research processing queue. |
| **Amazon SQS** | Decouples file ingestion from processing. Failed messages are retried according to the queue's redrive policy and moved to a dead-letter queue (DLQ) after exceeding the configured maximum receive count. |
| **AWS Lambda** | Python 3.12 CSV processor configured with 256 MB of memory and a 30-second timeout. Consumes SQS messages and writes JSON summaries to S3. |
| **Amazon RDS** | Private, encrypted MySQL database (`db.t3.micro`) with seven-day automated backup retention and database credentials managed through AWS Secrets Manager. |
| **Amazon EC2 Auto Scaling** | Private EC2 instances launched using a `t3.micro` launch template, with target-tracking scaling at 60% average CPU utilisation. Minimum capacity is 0, maximum capacity is 2, and desired capacity is initially 0 to avoid unnecessary lab costs. |
| **Amazon CloudWatch / SNS** | CloudWatch log group, processing-error metric filter, operational dashboard, CloudWatch alarms for processing failures and dead-letter queue activity, and an SNS notification topic. |


Data flow: S3 (Science/Medicine) → EventBridge → SQS → Lambda → processed S3. If requests fail repeatedly, they may be queued up in the DLQ to be investigated.

We have designated separate storage for our Science and Medicine Buckets. If the application needs to be deployed to production, then resources would need to be created for dedicated faculty-user access enforcement, which would also require additional IAM controls.

### Infrastructure as Code coverage

The CloudFormation template was checked for compliance with our PoC resource inventory. This submitted YAML contains 33 resource declarations, with the optional email subscription set to disabled (blank) by having no AlertEmail, so there are currently 32 CloudFormation-managed resources in the recorded configuration. There are also a number of resources that are hardcoded into the project inventory, specifically two IAM managed policies, an SNS email subscription and an SSM parameter. Then on this documented basis, the coverage is 32/36 x 100 = 88.9% which is greater than the assignment requirement of 80%. The template contains an explanation comment in front of each resource block. This is a calculation based on our inventory which we have recorded, not a live-account export.

## Submitted files

1. `Brief_C.yaml` — CloudFormation template, including inline Lambda application code.
2. `README.md` — deployment, verification, teardown and project notes (this file).

Our separate Python source, tests and GitHub Actions workflows are maintained in the project’s GitHub repository; they are not required as separate files in this two-file IaC hand-in: `https://github.com/Tahmid-35/brief-c-research-platform`.

## Prerequisites

-You have access to an AWS account or current AWS Academy Learner Lab session that grants you permission to deploy the resources in the template.
- An AWS region that is supported. We tested in **`us-east-1`**. An approved Australia Region and separate compliance/cost evaluation would be required for production.
-An existing IAM role named LabRole that will be passed to Lambda and LabInstanceProfile for the EC2 launch template. These are available in our Learner Lab, and require appropriate equivalents or a template change in our existing account.
- If EnableVpcLambda=true, the appropriate permissions are granted for the Lambda network interfaces.
- No sample research files for PoC testing that are sensitive.


## Deployment steps

1. Launch AWS Academy Learner Lab, open the AWS Console and choose **US East (N. Virginia)****.
2. Choose CloudFormation → Stacks → Create stack → With new resources (standard).
3. Select Upload a template file and pick the Brief_C.yaml.
4. Input a stack name (e.g. brief-c-research-poc) and check the following parameters:
   - LabRoleName=LabRole for the account for the lab being tested.
   Set EnableVpcLambda to true, if the existing role is already granted the necessary network-interface permissions, otherwise, set it to false and check back in a later update.
   - `AlertEmail` is optional. If offered, confirmation of the recipient of the SNS email subscription should be obtained. The test environment had an email subscription set up manually.
   The image that is resolved for the parameter LatestAmazonLinuxAmi is a public SSM parameter that can be changed at any time.
5. Check the resources and permissions, create the stack and watch **Events** until the operation is finished. If it is a new stack, the expected successful state is `CREATE_COMPLETE`.
6. In Outputs, verify the bucket names, queue URLs and the Dashboard name. Avoid assuming that the same names will be used for the resources in another account.
Before submitting a CSV file, be sure to check that the Lambda SQS event source mapping is set to Enabled. A failed mapping will prevent queued files from getting processed.

Update an existing stack: Check a CloudFormation change set prior to execution. In our previous review, we had discovered that an updated public AMI parameter can cause unplanned changes to the EC2 or Auto Scaling service. Never run an unapproved change set. The YAML submitted is the same Lambda v1.1 app logic used for the PoC, CloudFormation source for the deployed stack has not been reconciled with Lambda code change.

## Verification and recorded results

### 1. Infrastructure
- On cloudformation, ensure the stack is in a successful state and review the resources and outputs.
- Check that the Science and Medicine buckets, queue and DLQ, Lambda, private VPC networking, RDS, Auto Scaling group, CloudWatch dashboard and alarms are present.
-Make sure that the event source mapping for SQS to Lambda is set to **Enabled**.


### 2. End-to-end CSV processing

Create a CSV file that contains:

```csv
value
10
20
30
```

Put it into Science input bucket under a new objectkey. For the final post-CI/CD test we ran `deployment-tests/final-cicd-test.csv`, and examined the processed-output bucket for:

`science/deployment-tests/final-cicd-test.csv.summary.json`

The successful result was:

```json
{
  "faculty": "science",
  "source_key": "deployment-tests/final-cicd-test.csv",
  "records": 3,
  "total": 60.0,
  "mean": 20.0,
  "processor_version": "1.1"
}
```

This confirms that the application took in the research event, worked on the input and stored the correct summary in S3. Verify that the event source mapping, SQS queue, DLQ and Lambda log group are available before attempting output again if they are not.

### 3. Observability

Go to the CloudWatch dashboard: **`brief-c-research-poc-operations`** and check the Lambda invocations and errors, duration, SQS queue length and age and DLQ message count. In addition, the template contains Lambda-error, application-processing-error and DLQ alarms and a log metric filter for processing-error. During the PoC we were able to confirm an SNS test notification.

### 4. This is a successful deployment for GitHub Actions CI/CD, triggered by a commit.

We created and tested a GitHub Actions pipeline to run Python checks and deploy our Lambda application on push to the main branch. The GitHub environment of `lambda-deployment` only allows deployments on the `main` branch. To run the demonstrated workflow, commit **`684cacc`**. The deployment job successfully authenticated itself on AWS, packaged the Python application, updated the Lambda function, waited for the deployment to complete, and confirmed that the Lambda function is **`Active`** with the **`LastUpdateStatus: Successful`** status. We then executed the fresh CSV test above and checked that the output contained processor_version: 1.1.

How the GitHub pipeline authenticates: Temporary AWS Academy credentials were stored as encrypted GitHub environment secrets named AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN. They are not committed code or this submission - they are read at run time. AWS Academy credentials expire and should be refreshed in GitHub should there be a lab session change. This is appropriate for the lab demo; not a sustainable production delivery approach. In the production environment we recommend the use of GitHub OIDC with a dedicated least-privilege IAM deployment role and limited trust conditions.

## Safe teardown

We have not done a full test of removing and redeploying this PoC.These instructions are written for safe removal, but have not been fully tested.

1. Store the necessary evidence, test results and any S3 objects that need to be preserved.
2. Check CloudFormation resources, S3 bucket contents, and RDS snapshots and retention settings. Data can be removed by deleting a stack or charged resources can remain.
3. Once you have determined that deletion is appropriate, go to **CloudFormation → Stacks**, choose the stack and then select **Delete**.
4. Check for `DELETE_FAILED` or retained resources in stack Events. Check the status of database snapshots and separately managed resources (including IAM policies, the SNS subscription and the SSM parameter).
5. Show that remaining resources are either added back on purpose or cleaned up according to the lab procedures agreed upon by the project.

## AWS Academy Learner Lab scope and production approach

The lab limits the number of IAM roles or users and groups that can be created, Regions, and computing resources. We therefore showed the ability of the faculties to store input, but could not enforce independent faculties-user roles, and we tested with small test files, not with the full load of research on the faculties of the university. We will have access to a production AWS account and implement least-privilege access at storage and compute boundaries within all 12 faculties, we will utilise an appropriate Australian Region and will test workload specific batch/HPC processing, monitoring and data-governance controls.

We are now successfully demonstrating a deployment of our Lambda using temporary lab credentials that are renewed by the commit that is triggered. Instead, production deployment would use restricted OIDC authentication. Manual testing involved provisioning the RDS database and launching an Auto Scaling instance, but not showing application to RDS connectivity and CPU-trigged scaling. The tests, plus a full teardown/redeploy cycle, are still independent verification tasks.
