resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
  resource_group = ibm_resource_group.my_rg.id

  profile = "bx2-2x8"
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
