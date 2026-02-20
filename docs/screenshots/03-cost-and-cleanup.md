# Cost & Cleanup — Project 1: PCI-DSS Compliant E-Commerce Platform

## Overview

This document records the cost profile of every resource deployed
in this project and the teardown procedure used to eliminate ongoing
charges after validation.

---

## Resource Cost Reference

| Resource | Module | Billing Model | Estimated Cost |
|----------|--------|---------------|----------------|
| VPC, Subnets, IGW, Route Tables | 10-network | Free | $0.00 |
| Application Load Balancer | 20-edge-waf | ~$0.008/hr + LCU | < $0.10 |
| AWS WAFv2 Web ACL | 20-edge-waf | $5.00/mo + $0.60/million requests | < $0.10 |
| EC2 t3.micro | 25-app-ec2 | ~$0.0104/hr | < $0.05 |
| RDS db.t3.micro Multi-AZ | 30-data | ~$0.034/hr | < $0.10 |
| KMS Customer Managed Key | 30-data | $1.00/mo + API calls | < $0.05 |
| CloudTrail (first trail) | 40-logging-evidence | Free | $0.00 |
| S3 Logging Bucket | 40-logging-evidence | ~$0.023/GB/month | < $0.01 |
| VPC Flow Logs | 40-logging-evidence | ~$0.50/GB ingested | < $0.01 |
| CloudWatch Log Group | 40-logging-evidence | ~$0.50/GB ingested | < $0.01 |
| **Total Estimated** | | | **< $0.50** |

---

## Cost Control Strategy

### Principles followed in this project

* **Spin up, validate, destroy same session** — no resources left running
  overnight or between sessions
* **Destroy expensive resources first** — RDS Multi-AZ destroyed immediately
  after screenshots were taken
* **Use smallest instance sizes** — db.t3.micro and t3.micro throughout
* **Free tier where possible** — CloudTrail first trail is free,
  VPC components are free
* **No NAT Gateway** — intentionally excluded to save ~$0.045/hr
  ($32/month if left running)

### Most expensive resources to watch

* **RDS Multi-AZ** — most expensive resource in this project at ~$0.034/hr.
  Always destroy immediately after validation.
* **ALB** — billed while provisioned even with zero traffic.
  Destroy when not actively testing.
* **WAF** — $5.00/month base charge regardless of traffic.
  Destroy when not actively testing.
* **KMS CMK** — $1.00/month base charge.
  Deleting a KMS key requires a 7-day waiting period minimum.

---

## Teardown Procedure

### Important — always destroy in reverse order

Terraform modules have dependencies on each other. Destroying in the
wrong order will cause dependency errors. Always follow this exact order:

### Step 1 — Destroy 40-logging-evidence
```powershell
cd "Terraform/40-logging-evidence"
terraform destroy
# type: yes
```

### Step 2 — Destroy 25-app-ec2
```powershell
cd "../25-app-ec2"
terraform destroy
# type: yes
```

### Step 3 — Destroy 20-edge-waf
```powershell
cd "../20-edge-waf"
terraform destroy
# type: yes
```

### Step 4 — Destroy 10-network
```powershell
cd "../10-network"
terraform destroy
# type: yes
```

---

## Teardown Verification

After all modules are destroyed, verify in the AWS console:

| Service | What to check |
|---------|---------------|
| EC2 | No running instances |
| RDS | No database instances |
| VPC | No custom VPCs (only default VPC) |
| S3 | No pci-ecom-demo buckets |
| CloudTrail | No active trails |
| KMS | No customer managed keys (pending deletion) |
| CloudWatch | No pci-ecom-demo log groups |

---

## Final Teardown Record

| Date | Modules Destroyed | Resources | Confirmed By |
|------|-------------------|-----------|--------------|
| February 18, 2026 | All 5 modules | 33 total | Console verification |

**Current status: No infrastructure running — zero ongoing charges** 