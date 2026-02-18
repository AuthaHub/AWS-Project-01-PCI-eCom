resource "aws_security_group" "rds_sg" {
  name        = "${var.project_prefix}-rds-sg"
  description = "Allow MySQL access from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-rds-sg"
  })
}