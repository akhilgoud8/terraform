# resource "aws_instance" "sql_runner" {

#   ami = "ami-002192a70217ac181"

#   instance_type = "t2.micro"

#   subnet_id = aws_subnet.subnet-1.id

#   vpc_security_group_ids = [aws_security_group.my_security_group.id]



#   associate_public_ip_address = true



#   user_data = <<EOF

# #!/bin/bash

# yum update -y



# # Install MySQL client

# dnf install mysql -y || yum install mysql -y



# mkdir -p /home/ec2-user/sql

# chown ec2-user:ec2-user /home/ec2-user/sql

# EOF



#   tags = {

#     Name = "sql-runner"

#   }

# }



# resource "null_resource" "execute_sql" {



#   depends_on = [aws_instance.sql_runner]



#   connection {

#     type        = "ssh"
#     private_key = file("~/.ssh/id_ed25519")
#     host        = aws_instance.sql_runner.public_ip

#     user = "ec2-user"



#   }



#   provisioner "file" {

#     source = "${path.module}/scripts/init.sql"

#     destination = "/home/ec2-user/sql/init.sql"

#   }



#   provisioner "remote-exec" {

#     inline = [

#       "mysql -h ${aws_db_instance.primary.address} -u admin -pCloud123 dev < init.sql"

#     ]

#   }

# }
