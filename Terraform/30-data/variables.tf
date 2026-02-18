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

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from 10-network"
}

variable "app_sg_id" {
  type        = string
  description = "App EC2 security group ID from 25-app-ec2"
}

variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}