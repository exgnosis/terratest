
module "vm1" {
    source = "../modules/EC2"
    ami_type = var.amis[0]
    inst_type = var.insts[0]
    VM_name = var.names[0]

}

module "vm2" {
    source = "../modules/EC2"
    ami_type = var.amis[1]
    inst_type = var.insts[1]
    VM_name = var.names[1]

}

module "vm3" {
    source = "../modules/EC2"
     ami_type = var.amis[2]
    inst_type = var.insts[2]
    VM_name = var.names[2]

  }
