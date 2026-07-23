# SOURCE #2 of variable values: this .tfvars file.
# Terraform automatically loads a file named exactly "terraform.tfvars"
# without needing -var-file on the command line.
#
# Precedence reminderc (later overrides earlier):
#   1. variable "default" in variables.tf   (lowest priority)
#   2. terraform.tfvars / *.auto.tfvars     (this file)
#   3. -var-file=<file> on the CLI
#   4. -var="key=value" on the CLI
#   5. TF_VAR_<name> environment variables  (highest priority)
#
# NOTE: db_password is deliberately NOT set here — it has no default and
# must come from TF_VAR_db_password so it's never written to disk or git.

project_name         = "myapp"
environment          = "dev"
db_instance_class    = "db.t3.small"
db_allocated_storage = 30
db_multi_az          = false
