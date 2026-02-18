locals {
  # VPC CIDR (big enough for a demo)
  vpc_cidr = "10.0.0.0/16"

  # Use 2 AZs for realism (still cost-controlled)
  azs = ["us-east-1a", "us-east-1b"]

  # Public subnets (ALB will live here later)
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

  # Private subnets (app/data can live here later)
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Project = var.project_prefix
    Owner   = "Darnell"
    Env     = "demo"
  }
}
