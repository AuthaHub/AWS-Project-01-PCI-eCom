# Resume Bullets — Project 1: PCI-DSS Compliant E-Commerce Platform

> These bullets are for personal use — job applications, LinkedIn, and resume.
> This file is intentionally kept out of the public-facing README.

## Technical Bullets

* "Designed and deployed a PCI-DSS compliant e-commerce platform on AWS using
  Terraform IaC, implementing network segmentation, encryption at rest, and
  audit logging across 5 independent Terraform modules"

* "Configured AWS WAFv2 with OWASP managed rules on an Application Load Balancer
  to protect against SQL injection and XSS attacks per PCI-DSS Requirement 6.4"

* "Provisioned a Multi-AZ RDS MySQL instance with KMS customer-managed key
  encryption and automatic key rotation, meeting PCI-DSS Requirement 3.5 for
  cardholder data protection"

* "Implemented a full audit logging pipeline using CloudTrail with log file
  validation, VPC Flow Logs to CloudWatch, and an encrypted versioned S3 bucket
  meeting PCI-DSS Requirements 10.2, 10.3, and 10.4"

* "Troubleshot real-world Terraform issues including stale resource IDs across
  module boundaries and CloudTrail S3 bucket policy requirements — documented
  all issues, root causes, and fixes in a structured build log"

## Soft Skill Bullets

* "Practiced cost-conscious infrastructure management by spinning up expensive
  resources like Multi-AZ RDS only long enough to verify and document, then
  destroying immediately to minimize spend"

* "Documented every architecture decision with a specific PCI-DSS requirement
  rationale, mirroring how security engineers communicate compliance decisions
  in production environments"