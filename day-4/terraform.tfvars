app_bucket_name     = "my-companys3bucket"
trusted_account_arn = "arn:aws:iam::837563944836:user/cloud_user"

users = {
  alice = { groups = ["admins"] }
  bob   = { groups = ["developers"] }
  carol = { groups = ["readonly"], create_login_profile = true }
}
