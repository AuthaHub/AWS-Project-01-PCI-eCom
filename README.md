# Project 1 — PCI eCom Demo (Terraform)

## What this project demonstrates
- Built a reusable AWS network foundation (VPC + public/private subnets, routing) using Terraform.
- Deployed an edge layer with an internet-facing Application Load Balancer (ALB) and AWS WAF (managed rules baseline).
- Deployed a minimal application placeholder (EC2 + nginx) behind the ALB to validate end-to-end connectivity.
- Practiced cost control by tearing down billable resources after validation while keeping the network foundation for reuse.

## Architecture (high level)
Internet → ALB (public subnets) → Target Group → EC2 app (reachable only from ALB SG)  
WAF (regional) attached to ALB

## Security Controls (mapped to intent)

## Build Steps (Terraform)
### Prereqs
- AWS account + IAM user/role with permissions to create VPC/EC2/ALB/WAF
- Terraform installed
- AWS credentials configured (environment variables or AWS CLI profile)

### Recommended build order (module-by-module)
> Run each set of commands from inside that module folder.

#### 00-foundation (validation-only / state baseline)
```powershell
cd terraform/00-foundation
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
```

#### 10-network (creates VPC + subnets + routing)
```powershell
cd terraform/10-network
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

#### 20-edge-waf (creates ALB + WAF)
```powershell
cd terraform/20-edge-waf
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

#### 25-app-ec2 (creates EC2 app + registers to target group)
```powershell
cd terraform/25-app-ec2
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

## Evidence (Screenshots)
See `docs/screenshots/` for console validation screenshots for each phase.

## Cost Controls
### What costs money in this project
- ALB (20-edge-waf): billed while running
- AWS WAF (20-edge-waf): billed while enabled
- EC2 + EBS (25-app-ec2): billed while running / storage while exists
``

### Safe teardown order (to avoid dependency errors)
Destroy in reverse order of creation:
```powershell
cd terraform/25-app-ec2
terraform destroy
# type: yes

cd ../20-edge-waf
terraform destroy
# type: yes

Current status: 25-app-ec2, 20-edge-waf, and 10-network have been destroyed (no running infrastructure from Project 1).


## Lessons Learned / Interview Talk Track
- "I built a PCI-DSS compliant e-commerce platform entirely with Terraform,
  which taught me how compliance requirements translate directly into 
  infrastructure decisions — for example, why private subnets are required 
  for cardholder data under Requirement 1.3."

- "I learned to troubleshoot real-world Terraform issues including stale 
  resource IDs after destroy/rebuild cycles and CloudTrail S3 bucket policy 
  requirements — problems you only encounter by actually building."

- "I practiced cost-conscious infrastructure management by spinning up 
  expensive resources like Multi-AZ RDS only long enough to verify and 
  document them, then destroying immediately."

- "Every architecture decision in this project has a documented rationale 
  tied to a specific PCI-DSS requirement, which mirrors how security 
  engineers think about compliance in production environments."

## Project Status
**COMPLETE** — February 18, 2026

All modules built, verified, documented, and destroyed.

| Module | Resources | Status |
|--------|-----------|--------|
| 10-network | 13 | Complete |
| 20-edge-waf | 6 | Complete |
| 25-app-ec2 | 3 | Complete |
| 30-data | 7 | Complete |
| 40-logging-evidence | 11 | Complete |

## Compliance Coverage
| PCI-DSS Requirement | Implementation |
|---------------------|----------------|
| Req 1.2/1.3 | VPC segmentation, private subnets, security groups |
| Req 3.5 | KMS customer-managed keys for RDS encryption |
| Req 6.6 | WAF with OWASP managed rules |
| Req 10.2 | CloudTrail audit logging |
| Req 10.5 | Log file validation enabled |
| Req 10.6 | VPC Flow Logs to CloudWatch |
| Req 12.10 | Multi-AZ RDS for high availability |
