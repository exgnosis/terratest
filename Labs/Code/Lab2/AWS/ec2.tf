resource "aws_instance" "my_ec2" {
 ami           = "ami-0f403e3180720dd7e"
 #ami = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
 #instance_type = "t2.nano"

  tags = {
    Name = "Terraform"
    lab = "lab2"
  }
}
