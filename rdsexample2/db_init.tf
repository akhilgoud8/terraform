# -----------------------------------------------------------------------------
# DB initialization via null_resource + remote-exec.
#
# Why null_resource instead of provisioners directly on aws_instance.client:
#   Provisioners on a resource only fire when that resource is CREATED.
#   If you edit init.sql later, aws_instance.client shows no diff, so the SQL
#   never reruns unless you `terraform taint` the instance (which destroys
#   and recreates the whole EC2 box just to rerun a script).
#
#   null_resource lets you decouple "when to rerun SQL" from "when to
#   recreate infrastructure" via the `triggers` map below. Change init.sql,
#   its hash changes, only this resource reruns.
# -----------------------------------------------------------------------------

resource "null_resource" "db_init" {
  triggers = {
    sql_hash    = filesha256("${path.module}/init.sql")
    db_instance = aws_db_instance.primary.id
    ec2_instance = aws_instance.client.id
  }

  depends_on = [
    aws_db_instance.primary,
    aws_instance.client,
  ]

  connection {
    type        = "ssh"
    host        = aws_instance.client.public_ip
    user        = "ec2-user"
    private_key = file("${path.module}/${var.key_name}.pem")
  }

  provisioner "file" {
    source      = "${path.module}/init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
    inline = [
      # Poll instead of a fixed sleep — RDS can take well over 60s to become reachable.
      "echo 'Waiting for RDS endpoint to accept connections...'",
      "for i in $(seq 1 60); do mysqladmin ping -h ${aws_db_instance.primary.address} -u ${var.db_username} -p'${var.db_password}' --silent && break; echo 'not ready yet, retrying...'; sleep 10; done",

      # Use MYSQL_PWD env var rather than -p'...' so the password doesn't
      # show up in `ps aux` output on the instance.
      "MYSQL_PWD='${var.db_password}' mysql -h ${aws_db_instance.primary.address} -u ${var.db_username} ${var.db_name} < /tmp/init.sql",
      "echo 'init.sql applied successfully'",
    ]
  }
}

# -----------------------------------------------------------------------------
# ALTERNATIVE: without null_resource — provisioners live directly on the
# aws_instance resource instead. Uncomment this and remove/comment out the
# null_resource block above, plus strip the provisioner{} blocks out of ec2.tf
# if you go this route (can't have the same file/remote-exec logic in two
# places targeting the same connection).
#
# Tradeoff: simpler (one less resource), but editing init.sql later will NOT
# trigger a rerun automatically — you'd need `terraform taint aws_instance.client`,
# which destroys and recreates the EC2 instance.
# -----------------------------------------------------------------------------

# resource "aws_instance" "client_with_inline_provisioners" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t2.micro"
#   key_name                    = var.key_name
#   subnet_id                   = var.client_subnet_id
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true
#
#   user_data = <<-EOF
#     #!/bin/bash
#     yum update -y
#     yum install -y mariadb105
#   EOF
#
#   connection {
#     type        = "ssh"
#     host        = self.public_ip
#     user        = "ec2-user"
#     private_key = file("${path.module}/${var.key_name}.pem")
#   }
#
#   provisioner "file" {
#     source      = "${path.module}/init.sql"
#     destination = "/tmp/init.sql"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "for i in $(seq 1 60); do mysqladmin ping -h ${aws_db_instance.primary.address} -u ${var.db_username} -p'${var.db_password}' --silent && break; sleep 10; done",
#       "MYSQL_PWD='${var.db_password}' mysql -h ${aws_db_instance.primary.address} -u ${var.db_username} ${var.db_name} < /tmp/init.sql",
#     ]
#   }
#
#   depends_on = [aws_db_instance.primary]
# }
