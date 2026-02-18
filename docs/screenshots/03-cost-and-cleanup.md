## Phase 2 - Edge (ALB + WAF): Cost & Cleanup

### Services that may incur charges
- Application Load Balancer (ALB): billed while it exists (plus usage/data).
- AWS WAFv2 (Regional Web ACL): billed for the Web ACL, rule groups, and request volume.

### Cost-control approach
- Keep this layer up only while actively validating/testing.
- Capture evidence quickly (screenshots + outputs), then destroy when pausing work.

### Cleanup (destroy) command
From terraform/20-edge-waf:
- terraform destroy
- type: yes

### Notes
- Do NOT destroy 10-network until the entire project is complete (other phases depend on the VPC/subnets).

## Phase 3 - App Placeholder (EC2): Cost & Cleanup

### Services that may incur charges
- EC2 instance (t3.micro): billed while running.
- EBS volume (root disk): small storage cost while it exists.

### Cost-control approach
- Keep only one instance for validation/testing.
- Destroy the instance when pausing work to avoid ongoing compute charges.

### Cleanup (destroy) command
From terraform/25-app-ec2:
- terraform destroy
- type: yes

### Notes
- This phase depends on the ALB target group from 20-edge-waf.
- Do not destroy 20-edge-waf if you still need to test the ALB/WAF behavior.

