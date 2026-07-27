resource "aws_security_group" "rds_sg" {
  name        = "mysql-rds-sg"
  description = "Allow MySQL access from the EC2 client only"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "mysql-ec2-sg"
  description = "Allow SSH from admin IP, outbound to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Reference by security group instead of CIDR block — tighter and doesn't
# require tracking/updating the VPC CIDR manually.
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_db_subnet_group" "my_subnet_group" {
  name       = "mysql-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "mysql-rds-subnet-group"
  }
}
