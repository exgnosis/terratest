resource "aws_instance" "my_ec2" {
  count = length(var.owners)
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "VM-${count.index} ${var.owners[count.index]}"
  }
}
