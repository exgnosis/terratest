resource "aws_instance" "MyVM" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Name = "Demo VM"
    source = "terraform"
  }
}

