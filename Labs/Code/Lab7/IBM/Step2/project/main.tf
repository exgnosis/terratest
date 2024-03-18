
module "vm" {
    source = "../modules/vm"
    vm_image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
    vm_profile = "bx2-2x8"
}

module "vm1" {
    source = "../modules/vm"
    vm_image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
    vm_profile = "bx2-2x8"
}

