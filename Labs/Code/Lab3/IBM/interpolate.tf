output "VM_Profile" {
    description = "The profile used by my_vm"
    value = "The CM profile used in my VM is !{ibm_is_instance.my_vm.profile} "
}

output "SSH_Keys" {
    description = "The keys used by my_vm"
    value = "This ${tolist(ibm_is_instance.my_vm.keys)[0]} is the ssh key my VM uses"
}

output "My_Bucket_Name" {
    description = "The name of my bucket"
    value = "The name of my Object Bucket is ${ibm_cos_bucket.my_bucket.bucket_name} "
}

