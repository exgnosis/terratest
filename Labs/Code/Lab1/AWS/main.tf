resource "aws_instance" "my_rc2_instance" {
 ami           = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
  }
}