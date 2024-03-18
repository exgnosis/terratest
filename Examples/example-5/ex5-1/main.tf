resource "aws_instance" "the_servers" {
  count = 3
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    owner = var.server_owners[count.index]
    Name = "VM-${count.index}"
  }
}

