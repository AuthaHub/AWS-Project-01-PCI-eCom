resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-rds-subnet-group"
  })
}

resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_prefix}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  db_name  = "pcidb"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  tags = merge(local.tags, {
    Name = "${var.project_prefix}-mysql"
  })
}