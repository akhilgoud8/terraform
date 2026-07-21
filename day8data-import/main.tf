resource "aws_instance" "dev" {
  instance_type = var.instance_type
  ami           = var.ami_id
  tags = {
    Name = var.instance_name
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Suspended"
  }
}
