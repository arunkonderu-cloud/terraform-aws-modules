# modules/rds/main.tf
# RDS instance with Multi-AZ, encryption, automated backups

locals {
  common_tags = merge(var.tags, { Module = "rds", ManagedBy = "terraform" })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(local.common_tags, { Name = "${var.identifier}-subnet-group" })
}

resource "aws_security_group" "rds" {
  name        = "${var.identifier}-sg"
  description = "RDS security group - allows DB traffic from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "DB access from allowed security groups only"
  }

  tags = merge(local.common_tags, { Name = "${var.identifier}-sg" })
}

resource "aws_db_instance" "this" {
  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Security: Encryption at rest
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # High availability
  multi_az = var.multi_az

  # Backups
  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Security: No public access
  publicly_accessible = false

  # Security: Deletion protection in prod
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  # Monitoring
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true

  tags = merge(local.common_tags, { Name = var.identifier })
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.identifier}-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow",
      Principal = { Service = "monitoring.rds.amazonaws.com" } }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
