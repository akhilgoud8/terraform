name              = "my-app-alb"
vpc_id            = "vpc-01da395a158c21736"
ami_id            = "ami-01edba92f9036f76e"
instance_type     = "t3.micro"
instance_name     = "veera1"
subnet_id         = "subnet-0c3e878c98e7e8079"
public_subnet_ids = ["subnet-0c3e878c98e7e8079", "subnet-0ee0d9a7d27ca3561"]
internal          = false
target_port       = 80
target_type       = "instance"

health_check_path = "/health"

# Set to true and provide a certificate_arn to add HTTPS
enable_https    = false
certificate_arn = ""

ingress_cidr_blocks = ["0.0.0.0/0"]

tags = {
  Environment = "dev"
  Project     = "my-app"
}
