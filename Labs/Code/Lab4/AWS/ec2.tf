resource "aws_instance" "my_ec2" {
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "Terraform"
    lab  = "lab4"
  }
}
