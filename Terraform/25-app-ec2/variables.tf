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

variable "public_subnet_id" {
  type        = string
  description = "ONE public subnet ID from 10-network"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID from 20-edge-waf"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN from 20-edge-waf"
}
