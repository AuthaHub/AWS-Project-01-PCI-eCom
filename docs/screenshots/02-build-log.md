# Build Log — Project 1: PCI-DSS Compliant E-Commerce Platform

## Project Overview

| Field | Detail |
|-------|--------|
| Project | PCI-DSS Compliant E-Commerce Platform |
| Cloud Provider | AWS (us-east-1) |
| IaC Tool | Terraform |
| Start Date | February 18, 2026 |
| End Date | February 18, 2026 |
| Total Resources Deployed | 40 |
| Final Status | Complete — all resources destroyed |

---

## Module 1 — Network Foundation (10-network)

**Date:** February 18, 2026
**Status:** Complete

### Resources Created
| Resource | Name |
|----------|------|
| VPC | pci-ecom-demo-vpc |
| Public Subnet 1a | pci-ecom-demo-public-1a |
| Public Subnet 1b | pci-ecom-demo-public-1b |
| Private Subnet 1a | pci-ecom-demo-private-1a |
| Private Subnet 1b | pci-ecom-demo-private-1b |
| Internet Gateway | pci-ecom-demo-igw |
| Public Route Table | pci-ecom-demo-public-rt |
| Private Route Table | pci-ecom-demo-private-rt |

**Total resources:** 13
**terraform apply output:** Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

### Verification
- Confirmed public route table has 0.0.0.0/0 → IGW route
- Confirmed private route table has local route only — no internet route
- Confirmed 2 public and 2 private subnets across us-east-1a and us-east-1b

### Screenshots
- `docs/screenshots/10-network/P1-10-net-01-vpc-overview.png`
- `docs/screenshots/10-network/P1-10-net-02-subnets.png`
- `docs/screenshots/10-network/P1-10-net-03-public-route-table.png`
- `docs/screenshots/10-network/P1-10-net-04-private-route-table.png`

---

## Module 2 — Edge & WAF (20-edge-waf)

**Date:** February 18, 2026
**Status:** Complete

### Resources Created
| Resource | Name |
|----------|------|
| Application Load Balancer | pci-ecom-demo-alb |
| ALB Security Group | pci-ecom-demo-alb-sg |
| Target Group | pci-ecom-demo-tg |
| HTTP Listener | port 80 |
| WAFv2 Web ACL | pci-ecom-demo-waf |
| WAF Association | ALB → WAF |

**Total resources:** 6
**terraform apply output:** Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

### Verification
- Confirmed ALB status: Active
- Confirmed WAF attached to ALB
- Confirmed HTTP:80 listener forwarding to target group

### Screenshots
- `docs/screenshots/20-edge-waf/P1-20-edge-01-alb-overview.png`
- `docs/screenshots/20-edge-waf/P1-20-edge-02-alb-listener.png`
- `docs/screenshots/20-edge-waf/P1-20-edge-03-waf-association.png`

---

## Module 3 — Application Layer (25-app-ec2)

**Date:** February 18, 2026
**Status:** Complete

### Resources Created
| Resource | Name |
|----------|------|
| EC2 Instance | pci-ecom-demo-app |
| App Security Group | pci-ecom-demo-app-sg |
| Target Group Attachment | EC2 → pci-ecom-demo-tg |

**Total resources:** 3
**terraform apply output:** Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

### Verification
- Confirmed target group health check: 1 Healthy
- Confirmed ALB DNS returns nginx placeholder page
- Confirmed EC2 inbound restricted to ALB security group only

### Screenshots
- `docs/screenshots/25-app-ec2/P1-25-app-01-target-health.png`
- `docs/screenshots/25-app-ec2/P1-25-app-02-browser-alb.png`

---

## Module 4 — Data Layer (30-data)

**Date:** February 18, 2026
**Status:** ✅ Complete — destroyed same session

### Resources Created
| Resource | Name |
|----------|------|
| RDS MySQL Instance | pci-ecom-demo-mysql |
| DB Subnet Group | pci-ecom-demo-db-subnet-group |
| RDS Security Group | pci-ecom-demo-rds-sg |
| KMS Customer Managed Key | pci-ecom-demo-rds |
| KMS Key Alias | alias/pci-ecom-demo-rds |
| DB Parameter Group | default:mysql-8-0 |
| CloudWatch Log Group | /aws/rds/pci-ecom-demo |

**Total resources:** 7
**terraform apply output:** Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

### Verification
- Confirmed RDS status: Available
- Confirmed Multi-AZ: Yes — secondary in us-east-1b
- Confirmed Encryption: Enabled with KMS CMK pci-ecom-demo-rds
- Confirmed publicly_accessible: false
- Confirmed RDS inbound restricted to app security group on port 3306

### Screenshots
- `docs/screenshots/30-data/P1-30-data-01-rds-overview.png`
- `docs/screenshots/30-data/P1-30-data-02-rds-config.png`
- `docs/screenshots/30-data/P1-30-data-03-kms-key.png`
- `docs/screenshots/30-data/P1-30-data-04-rds-sg.png`

### Cost Note
RDS db.t3.micro Multi-AZ billed at ~$0.034/hr — destroyed same session.
Estimated cost: < $0.10

---

## Module 5 — Logging & Audit Evidence (40-logging-evidence)

**Date:** February 18, 2026
**Status:** ✅ Complete — destroyed same session

### Resources Created
| Resource | Name |
|----------|------|
| CloudTrail Trail | pci-ecom-demo-trail |
| S3 Logging Bucket | pci-ecom-demo-logs-xxxx |
| S3 Bucket Policy | CloudTrail + ALB write access |
| S3 Bucket Versioning | Enabled |
| S3 Encryption Configuration | AES-256 |
| S3 Public Access Block | All public access blocked |
| CloudWatch Log Group | /aws/vpc/flow-logs/pci-ecom-demo |
| VPC Flow Log | pci-ecom-demo-vpc-flow-logs |
| IAM Role | pci-ecom-demo-flow-logs-role |
| IAM Role Policy | pci-ecom-demo-flow-logs-policy |
| Random ID | S3 bucket suffix |

**Total resources:** 11
**terraform apply output:** Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

### Verification
- Confirmed CloudTrail status: Logging
- Confirmed log file validation: Enabled
- Confirmed S3 bucket versioning: Enabled
- Confirmed S3 public access: Fully blocked
- Confirmed VPC Flow Logs log group created in CloudWatch
- Confirmed 7-day retention on CloudWatch log group

### Screenshots
- `docs/screenshots/40-logging/P1-40-log-01-cloudtrail.png`
- `docs/screenshots/40-logging/P1-40-log-02-s3-logs-bucket.png`
- `docs/screenshots/40-logging/P1-40-log-03-vpc-flow-logs.png`

### Cost Note
CloudTrail first trail is free. S3 and CloudWatch minimal cost.
Estimated cost: < $0.05

---

## Troubleshooting Log

---

### Issue 1 — InvalidVpcID.NotFound on 20-edge-waf

**Date:** February 18, 2026
**Module:** 20-edge-waf
**Error:**
```
Error: InvalidVpcID.NotFound
```
**Cause:**
terraform.tfvars in 20-edge-waf still referenced the old vpc_id
from a previous destroyed build. After destroy/rebuild of 10-network,
all downstream module tfvars must be updated with fresh output values.

**Fix:**
Ran `terraform output` in 10-network and updated vpc_id,
public_subnet_ids, and private_subnet_ids in 20-edge-waf/terraform.tfvars.

**Lesson:**
After any destroy/rebuild cycle, always run `terraform output` in
each module and update all downstream tfvars before applying.

---

### Issue 2 — InvalidSubnetID.NotFound (subnet ID 'yes')

**Date:** February 18, 2026
**Module:** 25-app-ec2
**Error:**
```
Error: InvalidSubnetID.NotFound: subnet ID 'yes' does not exist
```
**Cause:**
Three separate issues compounded:
1. Stale subnet IDs in terraform.tfvars from previous build
2. Double bracket typo `[[` in public_subnet_ids value
3. Variable name mismatch — variables.tf declared `public_subnet_id`
   (singular) but tfvars used `public_subnet_ids` (plural)

**Fix:**
1. Updated all IDs from fresh terraform output values
2. Corrected double bracket to single bracket
3. Changed tfvars key to match singular variable declaration

**Lesson:**
Always copy/paste resource IDs — never manually type them.
Variable names must match exactly between variables.tf and tfvars.

---

### Issue 3 — CloudTrail InsufficientS3BucketPolicyException

**Date:** February 18, 2026
**Module:** 40-logging-evidence
**Error:**
```
Error: InsufficientS3BucketPolicyException
```
**Cause:**
S3 bucket policy was missing the CloudTrail-specific statements
required for CloudTrail to write logs. CloudTrail requires both
a GetBucketAcl statement and a PutObject statement with the
correct service principal.

**Fix:**
Rewrote the S3 bucket policy data source to include three statements:
1. AWSCloudTrailAclCheck — allows cloudtrail.amazonaws.com GetBucketAcl
2. AWSCloudTrailWrite — allows cloudtrail.amazonaws.com PutObject
3. ALBLogDelivery — allows ELB service account PutObject

**Lesson:**
CloudTrail has a specific S3 bucket policy format requirement.
Always use the CloudTrail service principal, not an IAM role ARN.

---

## Final Teardown Log

**Date:** February 18, 2026
**Reason:** Cost control — demo environment, resources not needed after validation

### Teardown Order
Destroyed in reverse dependency order to avoid Terraform errors:

| Order | Module | Resources Destroyed | Status |
|-------|--------|---------------------|--------|
| 1 | 40-logging-evidence | 11 | Destroyed |
| 2 | 25-app-ec2 | 3 | Destroyed |
| 3 | 20-edge-waf | 6 | Destroyed |
| 4 | 10-network | 13 | Destroyed |

**Total resources destroyed:** 33
**Final status:** No infrastructure running — zero ongoing charges

---

## Total Project Summary

| Module | Resources | Cost Estimate |
|--------|-----------|---------------|
| 10-network | 13 | < $0.01 |
| 20-edge-waf | 6 | < $0.10 |
| 25-app-ec2 | 3 | < $0.10 |
| 30-data | 7 | < $0.10 |
| 40-logging-evidence | 11 | < $0.05 |
| **Total** | **40** | **< $0.50** |