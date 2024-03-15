output "VM_Profile" {
    description = "The profile used by my_vm"
    value = ibm_is_instance.my_vm.profile
}

output "SSH_Keys" {
    description = "The keys used by my_vm"
    value = ibm_is_instance.my_vm.keys
}

output "My_Bucket_Name" {
    description = "The name of my bucket"
    value = ibm_cos_bucket.my_bucket.bucket_name
}


