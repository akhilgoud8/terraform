resource "aws_db_instance" "primary" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  identifier        = "mydbinstance"
  username          = "admin"
  password          = "Cloud123" #self managed password
  #managed_master_user_password = true  #enable password management by AWS Secrets Manager
  db_subnet_group_name   = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  #publicly_accessible  = true
  skip_final_snapshot     = true
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_retention_period = 7


}

# Use null_resource to execute the SQL script from your local machine
resource "null_resource" "local_sql_exec" {
  depends_on = [aws_db_instance.mysql_rds]

  provisioner "local-exec" {
    command = "mysql -h ${aws_db_instance.mysql_rds.address} -u admin -pCloud123 dev < init.sql"
  }

  triggers = {
    always_run = timestamp()
  }
}
