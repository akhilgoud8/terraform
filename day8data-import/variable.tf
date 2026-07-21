variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = ""

}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = ""
}
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = ""
}
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = ""
}
