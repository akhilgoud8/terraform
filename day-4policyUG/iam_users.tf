locals {
  # Maps the friendly group keys used in var.users to the actual group names.
  group_name_map = {
    admins     = aws_iam_group.admins.name
    developers = aws_iam_group.developers.name
    readonly   = aws_iam_group.readonly.name
  }
}

resource "aws_iam_user" "this" {
  for_each      = var.users
  name          = each.key
  path          = "/"
  force_destroy = var.force_destroy
  tags          = each.value.tags
}

# Manages the full set of group memberships for each user in one resource.
resource "aws_iam_user_group_membership" "this" {
  for_each = var.users
  user     = aws_iam_user.this[each.key].name
  groups   = [for g in each.value.groups : local.group_name_map[g]]
}

# Optional console login profile, only created when create_login_profile = true.
# WARNING: without a pgp_key, the generated password is stored in Terraform
# state in plaintext. Supply a pgp_key (see README) for production use.
resource "aws_iam_user_login_profile" "this" {
  for_each                = { for k, v in var.users : k => v if v.create_login_profile }
  user                    = aws_iam_user.this[each.key].name
  password_reset_required = true
}
