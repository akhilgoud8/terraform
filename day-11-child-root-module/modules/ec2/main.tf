resource "aws_instance" "ec2" {
  instance_type = var.ec2_instance_type
  ami           = var.ec2_ami_id

}
