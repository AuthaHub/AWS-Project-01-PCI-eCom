resource "aws_kms_key" "rds" {
  description             = "${var.project_prefix}-rds-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-rds-key"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}