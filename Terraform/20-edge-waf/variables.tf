variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefix for naming/tagging"
  type        = string
  default     = "pci-ecom-demo"
}

# From Phase 1 (network) - you will paste these values later
variable "vpc_id" {
  description = "VPC ID from 10-network"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from 10-network"
  type        = list(string)
}
