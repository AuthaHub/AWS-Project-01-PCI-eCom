variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_prefix" {
  type        = string
  description = "Prefix for naming/tagging"
  default     = "pci-ecom-demo"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from 10-network"
}

variable "alb_arn" {
  type        = string
  description = "ALB ARN from 20-edge-waf"
}

variable "waf_web_acl_arn" {
  type        = string
  description = "WAF Web ACL ARN from 20-edge-waf"
}