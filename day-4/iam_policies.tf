# -----------------------------------------------------------------------------
# Read-only access to a specific S3 bucket
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_readonly" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = ["arn:aws:s3:::${var.app_bucket_name}"]
  }

  statement {
    sid    = "GetObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = ["arn:aws:s3:::${var.app_bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_readonly" {
  name        = "S3ReadOnly-${var.app_bucket_name}"
  description = "Read-only access to the ${var.app_bucket_name} S3 bucket"
  policy      = data.aws_iam_policy_document.s3_readonly.json
}

# -----------------------------------------------------------------------------
# Developer policy: RW on the app bucket, EC2 describe, explicit deny on IAM/billing
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "developer" {
  statement {
    sid    = "S3ReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.app_bucket_name}",
      "arn:aws:s3:::${var.app_bucket_name}/*",
    ]
  }

  statement {
    sid       = "EC2ReadOnly"
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid       = "DenyIAMAndBilling"
    effect    = "Deny"
    actions   = ["iam:*", "aws-portal:*", "budgets:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer" {
  name        = "DeveloperPolicy"
  description = "Standard developer permissions: app bucket RW, EC2 describe, no IAM/billing"
  policy      = data.aws_iam_policy_document.developer.json
}

# -----------------------------------------------------------------------------
# MFA enforcement: deny everything except MFA self-service until MFA is enabled.
# Attach this to every human-user group alongside their functional policy.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid       = "AllowViewAccountInfo"
    effect    = "Allow"
    actions   = ["iam:GetAccountSummary", "iam:ListVirtualMFADevices"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowManageOwnMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}",
      "arn:aws:iam::*:user/$${aws:username}",
    ]
  }

  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "iam:ChangePassword",
      "sts:GetSessionToken",
    ]
    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "require_mfa" {
  name        = "RequireMFA"
  description = "Denies all actions except MFA self-service until MFA is enabled"
  policy      = data.aws_iam_policy_document.require_mfa.json
}
