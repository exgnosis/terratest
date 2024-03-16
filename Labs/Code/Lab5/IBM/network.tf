resource "ibm_is_vpc" "my_vpc" {
  name = "myvpc"
  resource_group = ibm_resource_group.my_rg.id
 tags              = [local.source, local.lab, local.team]
}

resource "ibm_is_subnet" "my_subnet" {
  name            = "mysubnet"
  vpc             = ibm_is_vpc.my_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}