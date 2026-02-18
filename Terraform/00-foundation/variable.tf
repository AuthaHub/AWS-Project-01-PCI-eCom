variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefix for naming/tagging (e.g., pci-ecom-demo)"
  type        = string
  default     = "pci-ecom-demo"
}
