resource "aws_s3_bucket" "my_bucket" {
  bucket = "zippy-the-wonder-llama-8879"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
