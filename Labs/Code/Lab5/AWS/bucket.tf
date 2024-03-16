resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Work Bucket"
   team = local.team
    source = local.source
    lab = local.lab
  }
}


