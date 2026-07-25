module "ec2" {
  source            = "./modules/ec2"
  ec2_ami_id        = var.ami_id
  ec2_instance_type = var.instance_type

}
module "s3" {
  source    = "./modules/s3"
  my_bucket = var.my_bucket

}
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
}
