# -----------------------------------------------------------------------------
# EC2 instance role: lets EC2 instances read from the app S3 bucket
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_app_role" {
  name               = "ec2-app-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_app_role_s3" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.s3_readonly.arn
}

resource "aws_iam_instance_profile" "ec2_app_role" {
  name = "ec2-app-role-profile"
  role = aws_iam_role.ec2_app_role.name
}

# -----------------------------------------------------------------------------
# Cross-account role: lets a trusted external account assume read-only access,
# gated by an ExternalId to protect against the confused-deputy problem.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "cross_account_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_account_arn]
    }
  }
}

resource "aws_iam_role" "cross_account_readonly" {
  name                 = "cross-account-readonly"
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.cross_account_assume_role.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "cross_account_readonly" {
  role       = aws_iam_role.cross_account_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
