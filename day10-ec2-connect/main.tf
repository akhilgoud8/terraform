# Generate SSH private/public key
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = "0400"
}


# AWS Key Pair
resource "aws_key_pair" "terraform_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}


# Security Group
resource "aws_security_group" "ec2_sg" {

  name        = "terraform-ec2-sg"
  description = "Allow SSH access"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  tags = {
    Name = "terraform-security-group"
  }
}


# EC2 Instance
resource "aws_instance" "amazon_linux" {

  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = aws_key_pair.terraform_key.key_name

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = var.instance_name
  }
}
