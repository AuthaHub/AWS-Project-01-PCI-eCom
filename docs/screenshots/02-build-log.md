## Phase 1.A - Network (Plan Only)

Terraform plan result:
- Plan: 13 to add, 0 to change, 0 to destroy.
## Phase 1.B - Network (APPLIED)

### Command
terraform apply

### Result
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

### Screenshots saved
- docs/screenshots/P1-10-network-01-vpc-overview.png
- docs/screenshots/P1-10-network-02-subnets.png
- docs/screenshots/P1-10-network-03-route-tables.png

### Verification
- Private route table has no 0.0.0.0/0 route (no direct internet routing)
- docs/screenshots/P1-10-network-04-private-rtb-no-internet.png

## Phase 2 - Edge (ALB + WAF)

### Goal
Expose the application tier through an internet-facing ALB while adding a WAF layer to reduce common web threats at the edge.

### Terraform (20-edge-waf)
- terraform plan: Plan: 6 to add, 0 to change, 0 to destroy.
- terraform apply: Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

### Outputs captured
- ALB DNS name captured (not pasted publicly)
- WAF Web ACL ARN captured (not pasted publicly)

### Evidence (screenshots)
- docs/screenshots/P1-20-edge-01-alb-overview.png
- docs/screenshots/P1-20-edge-02-alb-listener.png
- docs/screenshots/P1-20-edge-03-waf-associated.png

## Phase 3 - App Placeholder (EC2 behind ALB)

### Goal
Deploy a minimal, low-cost compute target so the ALB target group becomes healthy and the stack can be validated end-to-end.

### Terraform (25-app-ec2)
- terraform plan: Plan: 3 to add, 0 to change, 0 to destroy.
- terraform apply: Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

### Validation
- Target group shows Healthy target.
- ALB DNS returns the “App Placeholder” page.

### Evidence (screenshots)
- docs/screenshots/P1-25-app-01-target-health.png
- docs/screenshots/P1-25-app-02-app-page.png

### Teardown (cost control)
- Destroyed 25-app-ec2 after validation to stop EC2 charges.
- Destroyed 20-edge-waf after validation to stop ALB/WAF charges.
- Kept 10-network as the reusable foundation layer.

### Troubleshooting Log
Issue: terraform apply failed with InvalidSubnetID.NotFound
Cause: terraform.tfvars still referenced old subnet IDs from 
       previous build after destroy/rebuild cycle
Fix: Updated all IDs in tfvars to match new 10-network outputs
Lesson: After destroying and rebuilding, always update downstream 
        module tfvars with fresh output values

## Rebuild Session — February 18, 2026

### Reason for Rebuild
All modules destroyed at end of previous session for cost control. 
Full rebuild performed to complete remaining modules (30-data, 40-logging-evidence).

### Troubleshooting Log
**Issue 1:** terraform apply failed with InvalidSubnetID.NotFound on 20-edge-waf
**Cause:** terraform.tfvars still referenced old subnet/VPC IDs from previous build
**Fix:** Updated all IDs in tfvars to match new 10-network outputs
**Lesson:** After destroy/rebuild, always update downstream module tfvars with fresh output values

**Issue 2:** 25-app-ec2 failed with subnet ID 'yes' does not exist
**Cause:** Double bracket [[]] in public_subnet_ids and manual typing errors in tfvars
**Fix:** Corrected bracket syntax and used copy/paste for all IDs
**Lesson:** Always copy/paste resource IDs — never manually type them

**Issue 3:** CloudTrail S3 bucket policy insufficient permissions
**Cause:** Missing CloudTrail-specific policy statements (AclCheck + Write)
**Fix:** Added proper CloudTrail service principal statements to bucket policy
**Lesson:** CloudTrail requires specific S3 bucket policy format with service principal

### Phase 4 — 30-data
- Created: variables.tf, main.tf, kms.tf, security-groups.tf, rds.tf, outputs.tf, terraform.tfvars
- terraform plan: 7 to add
- terraform apply: Apply complete! Resources: 7 added
- Verified: RDS Multi-AZ = Yes, Encryption = Enabled, KMS key attached
- Screenshots taken and saved to docs/screenshots/30-data/
- terraform destroy: Resources: 7 destroyed (same session, cost control)

### Phase 5 — 40-logging-evidence
- Created: variables.tf, main.tf, s3-logging.tf, cloudtrail.tf, vpc-flow-logs.tf, outputs.tf, terraform.tfvars
- terraform plan: 11 to add
- terraform apply: Apply complete! Resources: 11 added
- Verified: CloudTrail active, VPC Flow Logs log group created, S3 logs bucket encrypted
- Screenshots taken and saved to docs/screenshots/40-logging/
- terraform destroy: Resources: 11 destroyed (same session, cost control)

## Final Project Status — February 18, 2026
- All 5 modules fully built, verified, documented, and destroyed
- Zero resources currently running in AWS
- Total estimated cost for today's session: < $1.00
- Safe to leave account idle — no ongoing charges