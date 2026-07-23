locals {
  # If no password was supplied, generate one automatically.
  password = var.password != "" ? var.password : random_password.master[0].result

  # Custom parameter group is only needed if the caller actually set parameters.
  needs_parameter_group = length(var.parameters) > 0
}

# ---------------------------------------------------------------------------
# Auto-generated password (used only when var.password is left blank)
# ---------------------------------------------------------------------------

resource "random_password" "master" {
  count = var.password == "" ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ---------------------------------------------------------------------------
# DB Subnet Group — tells RDS which subnets it's allowed to place ENIs in
# ---------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# ---------------------------------------------------------------------------
# Security Group — controls inbound access to the database port
# ---------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "${var.identifier}-rds-sg"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
  })
}

resource "aws_security_group_rule" "ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = local.effective_port
  to_port           = local.effective_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
  description       = "Allow DB access from specified CIDR blocks"
}

resource "aws_security_group_rule" "ingress_sg" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = local.effective_port
  to_port                  = local.effective_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.this.id
  description               = "Allow DB access from security group ${var.allowed_security_group_ids[count.index]}"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
}

locals {
  # Default ports by engine, used when var.port is not set
  default_ports = {
    mysql      = 3306
    mariadb    = 3306
    postgres   = 5432
    oracle-ee  = 1521
    oracle-se2 = 1521
    sqlserver-ex = 1433
    sqlserver-web = 1433
    sqlserver-se  = 1433
    sqlserver-ee  = 1433
  }

  effective_port = var.port != null ? var.port : lookup(local.default_ports, var.engine, 5432)
}

# ---------------------------------------------------------------------------
# Custom Parameter Group (only created if var.parameters is non-empty)
# ---------------------------------------------------------------------------

resource "aws_db_parameter_group" "this" {
  count = local.needs_parameter_group ? 1 : 0

  name   = "${var.identifier}-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.parameter_group_family != null
      error_message = "var.parameter_group_family must be set (e.g. \"postgres15\") when var.parameters is non-empty."
    }
  }
}

# ---------------------------------------------------------------------------
# RDS Instance
# ---------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  db_name  = var.db_name
  username = var.username
  password = local.password
  port     = local.effective_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = local.needs_parameter_group ? aws_db_parameter_group.this[0].name : null

  multi_az             = var.multi_az
  publicly_accessible  = var.publicly_accessible
  apply_immediately    = var.apply_immediately

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot      = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  deletion_protection      = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.identifier
  })

  lifecycle {
    ignore_changes = [
      # Avoid perpetual diffs if the password was auto-generated and
      # someone rotates it manually outside Terraform.
      password,
    ]
  }
}
