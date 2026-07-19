resource "aws_iam_group" "admins" {
  name = "admins"
  path = "/"
}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/"
}

resource "aws_iam_group" "readonly" {
  name = "readonly"
  path = "/"
}

# Admins get the AWS-managed AdministratorAccess policy.
# NOTE: this is still gated by the MFA-enforcement policy below.
resource "aws_iam_group_policy_attachment" "admins_admin" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "developers_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_group_policy_attachment" "readonly_policy" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.s3_readonly.arn
}

# Every human-user group must also enforce MFA
resource "aws_iam_group_policy_attachment" "admins_mfa" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

resource "aws_iam_group_policy_attachment" "developers_mfa" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.require_mfa.arn
}
