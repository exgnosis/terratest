output "VM_Profile" {
    description = "The profile used by my_vm"
    value = ibm_is_instance.my_vm.profile
}

output "VM_Image" {
    description = "The keys used by my_vm"
    value = ibm_is_instance.my_vm.image
}

output "My_Bucket_Name" {
    description = "The name of my bucket"
    value = ibm_cos_bucket.my_bucket.bucket_name
}

output "My_Resource_Name" {
    description = "Name of the resource group"
    value = ibm_resource_group.my_rg.name
}

