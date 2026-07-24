variable "ami_id" {
  description = "Amazon Linux AMI ID"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


variable "instance_name" {
  description = "EC2 Name tag"
  type        = string
}


variable "key_name" {
  description = "SSH key pair name"
  type        = string
}


variable "my_ip" {
  description = "Your public IP address"
  type        = string
}
