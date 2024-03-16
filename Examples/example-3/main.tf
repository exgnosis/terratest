resource "aws_instance" "my_vm" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Name = "Terraform"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

