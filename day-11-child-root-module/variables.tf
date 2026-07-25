variable "ami_id" {
  description = "Amazon Linux AMI ID"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string  

    }

variable "my_bucket" {
    description = "S3 bucket configuration"
    type        = string
}