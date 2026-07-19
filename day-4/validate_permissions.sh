#!/usr/bin/env bash
#
# validate_permissions.sh
#
# Validates the IAM setup created by this Terraform config using
# `aws iam simulate-principal-policy`, which evaluates a principal's
# actual attached/inline policies against specific actions and resources
# WITHOUT taking any real action (no resources are read or modified).
#
# Prerequisites:
#   - terraform apply has already run successfully in this directory
#   - AWS CLI v2 configured with credentials that have
#     iam:SimulatePrincipalPolicy permission
#   - jq installed
#
# Usage:
#   APP_BUCKET_NAME=my-company-app-data ./validate_permissions.sh

set -euo pipefail

BUCKET="${APP_BUCKET_NAME:?Set APP_BUCKET_NAME to the same value used in terraform.tfvars}"
RESOURCE_ARN="arn:aws:s3:::${BUCKET}/*"

pass=0
fail=0

check() {
  local label="$1" arn="$2" action="$3" expect="$4"
  local decision
  decision=$(aws iam simulate-principal-policy \
    --policy-source-arn "$arn" \
    --action-names "$action" \
    --resource-arns "$RESOURCE_ARN" \
    --query 'EvaluationResults[0].EvalDecision' \
    --output text)

  if [[ "$decision" == "$expect" ]]; then
    printf "  [PASS] %-8s %-28s expected=%-8s got=%s\n" "$label" "$action" "$expect" "$decision"
    ((pass++))
  else
    printf "  [FAIL] %-8s %-28s expected=%-8s got=%s\n" "$label" "$action" "$expect" "$decision"
    ((fail++))
  fi
}

echo "== Fetching ARNs from Terraform state =="
alice_arn=$(terraform output -json user_arns | jq -r '.alice')
bob_arn=$(terraform output -json user_arns | jq -r '.bob')
carol_arn=$(terraform output -json user_arns | jq -r '.carol')
ec2_role_arn=$(terraform output -json role_arns | jq -r '.ec2_app_role')
xacct_role_arn=$(terraform output -json role_arns | jq -r '.cross_account_readonly')

echo
echo "== admins (alice) — full access expected =="
check "alice" "$alice_arn" "s3:GetObject"        "allowed"
check "alice" "$alice_arn" "s3:PutObject"        "allowed"
check "alice" "$alice_arn" "iam:CreateUser"      "allowed"

echo
echo "== developers (bob) — app-bucket RW, EC2 describe, IAM denied =="
check "bob" "$bob_arn" "s3:GetObject"        "allowed"
check "bob" "$bob_arn" "s3:PutObject"        "allowed"
check "bob" "$bob_arn" "iam:CreateUser"      "explicitDeny"

echo
echo "== readonly (carol) — read only, write and IAM denied =="
check "carol" "$carol_arn" "s3:GetObject"        "allowed"
check "carol" "$carol_arn" "s3:PutObject"        "implicitDeny"
check "carol" "$carol_arn" "iam:CreateUser"      "implicitDeny"

echo
echo "== ec2-app-role — read only =="
check "ec2-role" "$ec2_role_arn" "s3:GetObject" "allowed"
check "ec2-role" "$ec2_role_arn" "s3:PutObject" "implicitDeny"

echo
echo "== cross-account-readonly role — AWS ReadOnlyAccess, no writes/IAM writes =="
check "xacct-role" "$xacct_role_arn" "s3:GetObject"   "allowed"
check "xacct-role" "$xacct_role_arn" "s3:PutObject"   "implicitDeny"
check "xacct-role" "$xacct_role_arn" "iam:CreateUser" "implicitDeny"

echo
echo "-----------------------------------------"
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
