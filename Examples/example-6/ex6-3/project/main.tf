
module "vm1" {
    source = "../modules/EC2"
    ami_type = "ami-0d7a109bf30624c99"
    inst_type = "t2.medium"
    VM_name = "VM-1"

}

module "vm2" {
    source = "../modules/EC2"
    inst_type = "t2.micro"
    VM_name = "VM-2"
}

module "VM-1" {
    source = "../modules/EC2"
    VM_name = "VM-3"
  }
