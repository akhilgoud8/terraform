
# Use null_resource to execute the SQL script from your local machine
resource "null_resource" "local_sql_exec" {
  depends_on = [aws_db_instance.primary]

  provisioner "local-exec" {
    command = "mysql -h ${aws_db_instance.primary.address} -u admin -pCloud123 dev < init.sql"
  }

  triggers = {
    always_run = timestamp()
  }
}
