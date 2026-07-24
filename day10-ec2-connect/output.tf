output "instance_public_ip" {

  description = "EC2 Public IP"

  value = aws_instance.amazon_linux.public_ip
}


output "ssh_command" {

  description = "SSH command"

  value = "ssh -i ec2-key.pem ec2-user@${aws_instance.amazon_linux.public_ip}"
}


output "key_file" {

  value = local_file.private_key.filename
}
