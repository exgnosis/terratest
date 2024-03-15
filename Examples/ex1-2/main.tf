resource "aws_instance" "my_vm" {
  instance_type = "t2.micro"
  ami           = "ami-0f403e3180720dd7e"
  tags = {
    Name = "Demo VM"
    source = "terraform"
  }
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "zippy-the-wonder-llama"
    tags = {
        source = "terraform"
    }
}

data "aws_vpc" "default_vpc" {
    default = true
}