resource "aws_instance" "my_vm" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Source = local.source
    Team = local.team
    Name = "Main Server"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
   Source = local.source
    Team = local.team
  }
}

