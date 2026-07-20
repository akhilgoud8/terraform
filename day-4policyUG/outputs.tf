output "user_arns" {
  description = "ARNs of all created IAM users, keyed by username"
  value       = { for k, u in aws_iam_user.this : k => u.arn }
}

output "group_arns" {
  description = "ARNs of the three IAM groups"
  value = {
    admins     = aws_iam_group.admins.arn
    developers = aws_iam_group.developers.arn
    readonly   = aws_iam_group.readonly.arn
  }
}

output "role_arns" {
  description = "ARNs of the IAM roles"
  value = {
    ec2_app_role           = aws_iam_role.ec2_app_role.arn
    cross_account_readonly = aws_iam_role.cross_account_readonly.arn
  }
}

output "policy_arns" {
  description = "ARNs of the custom-managed policies"
  value = {
    s3_readonly = aws_iam_policy.s3_readonly.arn
    developer   = aws_iam_policy.developer.arn
    require_mfa = aws_iam_policy.require_mfa.arn
  }
}
