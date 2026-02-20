# Architecture Decisions — Project 1: PCI-DSS Compliant E-Commerce Platform

## Overview

This document records every architecture decision made during the design
and deployment of a PCI-DSS compliant e-commerce platform on AWS. Each
decision includes the rationale, the alternative considered, and the
specific PCI-DSS v4.0.1 requirement it satisfies.

**Compliance Framework:** PCI-DSS v4.0.1
**Cloud Provider:** AWS (us-east-1)
**IaC Tool:** Terraform
**Deployment Model:** Demo/Portfolio — resources destroyed after validation

---

## Module 1 — Network Foundation (10-network)

### Decision: Multi-AZ VPC with Public and Private Subnets

**What was built:**
VPC (10.0.0.0/16) with 2 public subnets and 2 private subnets across
us-east-1a and us-east-1b.

**Why:**
PCI-DSS requires the cardholder data environment (CDE) to be isolated
from untrusted networks. Separating public and private subnets ensures
that database and application resources are never directly reachable
from the internet.

**Alternative considered:**
Single public subnet for all resources — rejected because it would
place the database on a publicly routable network, violating PCI-DSS.

**PCI-DSS Requirement satisfied:**
> Req 1.2: Network security controls are configured to restrict
> inbound and outbound traffic to only what is necessary.

---

### Decision: Private Subnets with No Internet Route

**What was built:**
Private route tables with only a local route (10.0.0.0/16) — no
0.0.0.0/0 route to the Internet Gateway.

**Why:**
Resources in the CDE must not have direct internet access. Removing
the default route from private route tables enforces this at the
network layer rather than relying solely on security groups.

**Alternative considered:**
NAT Gateway for outbound internet access from private subnets —
rejected for this demo due to cost ($0.045/hr). Not required for
the application placeholder being deployed.

**PCI-DSS Requirement satisfied:**
> Req 1.3: Network access controls prohibit direct public access
> to any component in the cardholder data environment.

---

## Module 2 — Edge & WAF (20-edge-waf)

### Decision: Internet-Facing ALB in Public Subnets

**What was built:**
Application Load Balancer deployed across both public subnets,
accepting inbound HTTP:80 traffic from the internet.

**Why:**
The ALB acts as the single entry point for all inbound traffic,
ensuring no direct internet access to application or database tiers.
All traffic must pass through the ALB before reaching any private
resource.

**Alternative considered:**
Direct EC2 public IP — rejected because it would bypass WAF
protection and expose the application tier directly to the internet.

**PCI-DSS Requirement satisfied:**
> Req 1.2: All traffic to the cardholder data environment passes
> through a controlled, monitored entry point.

---

### Decision: AWS WAFv2 with OWASP Managed Rules

**What was built:**
WAFv2 Regional Web ACL with AWSManagedRulesCommonRuleSet attached
directly to the ALB.

**Why:**
Web-facing applications processing payment data must be protected
against common web exploits including SQL injection and cross-site
scripting. AWS managed rules provide continuously updated protection
without requiring manual rule maintenance.

**Alternative considered:**
No WAF — rejected because unprotected web applications are a primary
attack vector for cardholder data theft and violate PCI-DSS.

**PCI-DSS Requirement satisfied:**
> Req 6.4: Web-facing applications are protected against known attacks
> by deploying a web application firewall in front of the application.

---

## Module 3 — Application Layer (25-app-ec2)

### Decision: EC2 in Private Subnet Behind ALB

**What was built:**
EC2 t3.micro running nginx deployed in a private subnet, registered
to the ALB target group via private IP address.

**Why:**
Application servers must not be directly internet-accessible. Placing
EC2 in a private subnet and routing all traffic through the ALB ensures
the application tier is only reachable through the controlled entry point.

**Alternative considered:**
EC2 in public subnet with public IP — rejected because it would expose
the application tier directly to the internet, bypassing WAF protection.

**PCI-DSS Requirement satisfied:**
> Req 1.3: Network access controls prohibit direct public access to
> any component in the cardholder data environment.

---

### Decision: App Security Group Allowing Inbound Only from ALB SG

**What was built:**
EC2 security group with a single inbound rule — port 80 from the
ALB security group ID only. No inbound from 0.0.0.0/0.

**Why:**
Least privilege network access ensures that even if the ALB were
compromised, lateral movement to other resources is restricted.
Referencing the ALB security group ID rather than a CIDR range
is more precise and adapts automatically if ALB IPs change.

**Alternative considered:**
Inbound from 0.0.0.0/0 on port 80 — rejected because it would
allow any internet host to bypass the ALB and connect directly
to the application server.

**PCI-DSS Requirement satisfied:**
> Req 1.2: Network security controls restrict inbound and outbound
> traffic to only what is necessary for each system component.

---

## Module 4 — Data Layer (30-data)

### Decision: RDS MySQL in Private Subnets with publicly_accessible = false

**What was built:**
RDS MySQL 8.0 instance deployed in private subnets via a DB subnet
group. publicly_accessible explicitly set to false in Terraform.

**Why:**
Databases containing cardholder data must never be directly reachable
from the internet. Deploying in private subnets and disabling public
accessibility enforces this at both the network and RDS service level.

**Alternative considered:**
RDS in public subnet for easier access during development — rejected
because any database storing or processing payment data must be
isolated from public networks regardless of environment.

**PCI-DSS Requirement satisfied:**
> Req 1.3: Prohibit direct public access to any component in the
> cardholder data environment.

---

### Decision: Multi-AZ RDS for High Availability

**What was built:**
RDS Multi-AZ enabled — AWS automatically provisions a synchronous
standby replica in us-east-1b with automatic failover.

**Why:**
Payment processing platforms must maintain availability to avoid
business disruption. Multi-AZ provides automatic failover without
manual intervention if the primary instance fails.

**Alternative considered:**
Single-AZ RDS — rejected because a single database instance creates
a single point of failure, risking extended downtime during incidents.

**PCI-DSS Requirement satisfied:**
> Req 12.10: Incident response plan includes roles and procedures
> for responding to system failures affecting the CDE.

---

### Decision: KMS Customer-Managed Key for RDS Encryption

**What was built:**
KMS customer-managed key (CMK) with automatic annual rotation,
used to encrypt all RDS storage at rest.

**Why:**
Customer-managed keys provide full control over key rotation policy
and access permissions. Automatic rotation limits the exposure window
if a key is ever compromised. AWS-managed keys do not provide the
same level of access control visibility.

**Alternative considered:**
AWS-managed RDS encryption key — rejected because CMKs provide
auditable key usage logs in CloudTrail and explicit rotation control,
both required for demonstrating PCI-DSS compliance.

**PCI-DSS Requirement satisfied:**
> Req 3.5: Primary account numbers are secured with strong
> cryptography wherever stored.

---

### Decision: RDS Security Group Allowing Port 3306 from App SG Only

**What was built:**
RDS security group with a single inbound rule — MySQL port 3306
from the application EC2 security group ID only.

**Why:**
The database tier should only accept connections from the application
tier directly above it. Referencing the app security group ID enforces
this without relying on IP address ranges that may change.

**Alternative considered:**
Open port 3306 to the entire VPC CIDR — rejected because it would
allow any resource in the VPC to connect to the database, violating
least privilege principles.

**PCI-DSS Requirement satisfied:**
> Req 1.2: Network security controls restrict traffic to only what
> is necessary for each system component.

---

## Module 5 — Logging & Audit Evidence (40-logging-evidence)

### Decision: CloudTrail with Log File Validation

**What was built:**
CloudTrail trail capturing all API calls account-wide, delivering
logs to S3 with log file validation enabled.

**Why:**
Every action taken in the AWS account — who did what, when, and
from where — must be recorded and tamper-evident. Log file validation
creates a digest file that can prove logs have not been modified
after delivery.

**Alternative considered:**
CloudWatch Logs only — rejected because CloudTrail provides
structured API-level audit records that CloudWatch alone cannot
replicate, and log file validation is a specific PCI-DSS control.

**PCI-DSS Requirement satisfied:**
> Req 10.2: Audit logs capture all individual user access to
> cardholder data and all actions taken by individuals with root
> or administrative privileges.
> Req 10.3: Audit logs are protected from destruction and
> unauthorized modification.

---

### Decision: VPC Flow Logs to CloudWatch with 7-Day Retention

**What was built:**
VPC Flow Logs capturing ALL traffic (accepted and rejected) sent
to a CloudWatch log group with 7-day retention.

**Why:**
Network traffic logs enable detection of unusual connection patterns,
port scanning, and unauthorized access attempts. Capturing both
accepted and rejected traffic provides a complete network audit trail.

**Alternative considered:**
Flow logs to S3 directly — CloudWatch was chosen because it enables
real-time log insights and metric filters for alerting in future
iterations. 7-day retention chosen for cost control in demo environment
— production would require minimum 12 months per PCI-DSS.

**PCI-DSS Requirement satisfied:**
> Req 10.6: Audit log reviews cover all system components and
> include network traffic analysis.
> Req 10.7: Audit log history is retained for at least 12 months
> (noted: demo uses 7 days for cost control).

---

### Decision: S3 Logging Bucket with Encryption, Versioning, and Public Access Block

**What was built:**
S3 bucket with AES-256 server-side encryption, versioning enabled,
and all public access settings blocked. Bucket policy restricts
writes to CloudTrail and ALB service principals only.

**Why:**
Log files are only valuable as evidence if they cannot be deleted
or modified. Versioning prevents accidental or malicious deletion.
Encryption protects sensitive audit data at rest. Public access
block prevents any misconfiguration from exposing log data.

**Alternative considered:**
Unencrypted S3 bucket without versioning — rejected because
unprotected log storage fails multiple PCI-DSS controls and
renders audit evidence inadmissible for compliance purposes.

**PCI-DSS Requirement satisfied:**
> Req 10.3: Protect audit logs from destruction and unauthorized
> modifications.
> Req 10.4: Secure audit logs to prevent unauthorized access.