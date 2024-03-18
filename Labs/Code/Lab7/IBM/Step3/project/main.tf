
module "vm" {
    source = "../modules/vm"
    vm_image = var.vm_image
    vm_profile = var.vm_profile
}

