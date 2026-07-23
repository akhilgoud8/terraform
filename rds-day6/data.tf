# ---------------------------------------------------------------------------
# SOURCE: live data source lookups against AWS itself, instead of hardcoding
# IDs. Falls back to var.vpc_id_override / var.subnet_ids_override when set
# (handy for tests, or when you already know the IDs and want to skip a
# lookup that requires real AWS credentials).
# ---------------------------------------------------------------------------

variable "subnet_ids_override" {
  type    = list(string)
  default = null
}

data "aws_vpc" "selected" {
  count   = var.vpc_id_override == null ? 1 : 0
  default = true
}

data "aws_subnets" "private" {
  count = var.subnet_ids_override == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    Tier = "private"
  }
}

locals {
  vpc_id = var.vpc_id_override != null ? var.vpc_id_override : data.aws_vpc.selected[0].id

  subnet_ids = var.subnet_ids_override != null ? var.subnet_ids_override : data.aws_subnets.private[0].ids
}
