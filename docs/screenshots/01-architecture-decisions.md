## Phase 1 - Network Segmentation

- Decision: Use public + private subnets to separate internet-facing resources from internal tiers.
- Why: Supports segmentation/scoping intent for PCI-style architecture; only edge components live in public subnets while application/data tiers remain private. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

## Phase 2 - Edge Protection (ALB + WAF)

### Decision: Use an Application Load Balancer (ALB) as the internet-facing entry point
**Why:** Centralizes inbound HTTP handling, provides a clean routing/control point, and sets the foundation for adding security controls (WAF) and future TLS termination.

### Decision: Attach AWS WAFv2 (Regional) to the ALB using an AWS Managed Rules baseline
**Why:** Adds a first-line control at the edge to help block common web attack patterns before traffic reaches application tiers. Starting with AWS Managed Rules provides immediate coverage while keeping the rule set standardized and explainable.

### Cost/Scope note
WAF + ALB are intentionally deployed as a scoped “edge layer” so they can be validated quickly (screenshots + outputs) and destroyed when not actively being tested to control spend.

## Phase 3 - Application Placeholder (EC2)

### Decision: Use a single EC2 instance as a temporary application target
**Why:** This provides the fastest, lowest-complexity way to validate the edge layer (ALB + WAF) with a real backend response. It enables end-to-end testing and portfolio evidence without committing to a full container platform yet.

### Decision: Restrict inbound traffic to the instance from the ALB security group only
**Why:** The instance is not directly exposed to the internet. Only the ALB can reach it on HTTP/80, which mirrors real-world patterns where the load balancer is the controlled ingress point.

### Note on future evolution
This placeholder can be replaced later with a more production-like target (ECS/Fargate or an Auto Scaling Group) once the architecture is validated.

## Phase 4 — 30-data Architecture Decisions

**Why RDS MySQL Multi-AZ?**
Multi-AZ provides automatic failover to a standby instance in a separate 
Availability Zone, ensuring high availability for cardholder data storage. 
This meets PCI-DSS Requirement 12.10 for business continuity.

**Why KMS Customer-Managed Keys for RDS encryption?**
Customer-managed keys provide full control over key rotation policies and 
access permissions. This meets PCI-DSS Requirement 3.5 for protecting 
stored cardholder data with strong cryptography.

**Why private subnets for RDS?**
Database instances must never be directly internet-accessible. Placing RDS 
in private subnets with no internet gateway route enforces network 
segmentation and meets PCI-DSS Requirement 1.3.

**Why security group allowing MySQL only from app tier?**
Least privilege network access — only the application EC2 security group 
can reach port 3306. This prevents lateral movement and unauthorized 
database access, meeting PCI-DSS Requirement 1.2.

**Why skip_final_snapshot = true for demo?**
Cost control for portfolio environment. In production this would be set 
to false with a named final snapshot for disaster recovery.

## Phase 5 — 40-logging-evidence Architecture Decisions

**Why CloudTrail?**
CloudTrail provides a complete audit trail of all API calls made in the 
AWS account — who did what, when, and from where. This meets PCI-DSS 
Requirement 10.2 for audit log implementation.

**Why log file validation enabled?**
Log file validation creates a digest file that can be used to verify 
logs have not been tampered with after delivery. This meets PCI-DSS 
Requirement 10.5 for protecting audit logs from modification.

**Why VPC Flow Logs to CloudWatch?**
VPC Flow Logs capture all network traffic metadata flowing through the 
VPC, enabling network traffic analysis and anomaly detection. This meets 
PCI-DSS Requirement 10.6 for reviewing logs and security events.

**Why S3 with versioning and encryption for log storage?**
Versioning prevents accidental deletion of log files. Encryption at rest 
protects sensitive audit data. Public access block prevents exposure of 
log data. These controls meet PCI-DSS Requirement 10.7 for retaining 
audit logs.

**Why 7-day CloudWatch retention for flow logs?**
Cost-conscious retention period for demo environment. In production, 
PCI-DSS Requirement 10.7 requires minimum 12 months retention with 3 
months immediately available.

## Architecture Diagram
![Architecture Diagram](docs/screenshots/P1-architecture-diagram.png)

> Note: Diagramming is an area I'm actively improving. This diagram 
> represents the architecture as built — future iterations will reflect 
> improved visual design as I develop this skill alongside my technical work.
