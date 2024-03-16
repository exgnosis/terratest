resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image
  resource_group = ibm_resource_group.my_rg.id
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]

  profile = var.vm_profile
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
