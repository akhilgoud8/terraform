variable "name" {
  description = "Base name used for the ALB and related resources"
  type        = string
  default     = "my-app-alb"
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type    = string
  default = ""
}

variable "instance_name" {
  type    = string
  default = ""
}
variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target group will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to attach the ALB to (at least 2, in different AZs)"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port on which targets (e.g. EC2 instances/ECS tasks) receive traffic"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Type of target: instance, ip, or lambda"
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Path used by the target group health check"
  type        = string
  default     = "/"
}

variable "enable_https" {
  description = "Whether to create an HTTPS (443) listener. Requires certificate_arn."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener (required if enable_https = true)"
  type        = string
  default     = ""
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB on HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
