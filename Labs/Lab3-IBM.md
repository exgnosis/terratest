# Lab IBM 3 - Terraform Output Directives

##### Working with output directives

---

## Objectives

In this lab, you will create some outputs to add to the code from the previous lab.

## Setup
 
You can re-use the code from the previous lab.

You should have a `providers.tf` file

```terraform
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~> 1.0"
    }
  }
}

provider "ibm" {
 region = "us-south"
}
```

And a `resource_group.tf` file

```terraform
resource "ibm_resource_group" "my_rg" {
  name = "Lab3"
}
```

And a `sshkeys.tf` file

```terraform
resource "ibm_is_ssh_key" "my_ssh_key" {
  resource_group = ibm_resource_group.my_rg.id
  name       = "lab2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
  type       = "rsa"
}
```

And a `network.rf` file

```terraform
resource "ibm_is_vpc" "my_vpc" {
  name = "myvpc"
  resource_group = ibm_resource_group.my_rg.id
}

resource "ibm_is_subnet" "my_subnet" {
  name            = "mysubnet"
  vpc             = ibm_is_vpc.my_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}
```

And a `compute.tf` file

```terraform
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
```

And finally, a `bucket.tf` file

```terraform
resource "ibm_resource_instance" "my_cos" {
  name              = "mycos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = ibm_resource_group.my_rg.id
  tags              = ["terraform", "Lab3"]
}

resource "ibm_cos_bucket" "my_bucket" {
  bucket_name          = "zippy-the-wonder-llama-9989"
  resource_instance_id = ibm_resource_instance.my_cos.id
  region_location      = "us-south"
  storage_class        = "standard"
}
```

## Deploy the infrastructure

Use `terraform validate` the use `terraform plan` to review your infrastructure. Once it passes, then run `terraform apply` to get it up and running.

Confirm at the console like you did in the previous lab that the resources are deployed.

```console
ibm_resource_group.my_rg: Creating...
ibm_resource_group.my_rg: Creation complete after 1s [id=09ce2b81970b47cfa2a2d62188151e27]
ibm_resource_instance.my_cos: Creating...
ibm_is_vpc.my_vpc: Creating...
ibm_is_ssh_key.my_ssh_key: Creating...
ibm_is_ssh_key.my_ssh_key: Creation complete after 2s [id=r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af]
ibm_resource_instance.my_cos: Still creating... [10s elapsed]
ibm_is_vpc.my_vpc: Still creating... [10s elapsed]
ibm_is_vpc.my_vpc: Creation complete after 15s [id=r006-e5b5de9c-f621-44a4-9a76-23d530cc3cb2]
ibm_is_subnet.my_subnet: Creating...
ibm_resource_instance.my_cos: Creation complete after 15s [id=crn:v1:bluemix:public:cloud-object-storage:global:a/b420fb31a3024a2e8b44e928ed41f042:abe08bfe-2752-4e1e-b398-2731c97317e8::]
ibm_cos_bucket.my_bucket: Creating...
ibm_cos_bucket.my_bucket: Creation complete after 3s [id=crn:v1:bluemix:public:cloud-object-storage:global:a/b420fb31a3024a2e8b44e928ed41f042:abe08bfe-2752-4e1e-b398-2731c97317e8:bucket:zippy-the-wonder-llama-9989:meta:rl:us-south:public]
ibm_is_subnet.my_subnet: Still creating... [10s elapsed]
ibm_is_subnet.my_subnet: Creation complete after 13s [id=0717-f5af3374-d6a7-4dd8-9ec6-96295cc7a01f]
ibm_is_instance.my_vm: Creating...
ibm_is_instance.my_vm: Still creating... [10s elapsed]
ibm_is_instance.my_vm: Creation complete after 13s [id=0717_55247f55-3085-4efd-a96e-bb85fe6ad70d]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

## Add the outputs

Add a new file called `outputs.tf` that looks like this:

```terraform 
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
```

Rerun `terraform apply`. Notice that the only change that Terraform makes is to produce the output file.

```console
Changes to Outputs:
  + My_Bucket_Name = "zippy-the-wonder-llama-9989"
  + SSH_Keys       = [
      + "r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af",
    ]
  + VM_Profile     = "bx2-2x8"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Outputs:

My_Bucket_Name = "zippy-the-wonder-llama-9989"
SSH_Keys = toset([
  "r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af",
])
VM_Profile = "bx2-2x8"
```

Notice that the value for the keys looks different from the other outputs. This is because a VM can have more than one ssh ket associated with it. The `[]` indicate that this may be a list, in this case of just one item. The `toset()` operation eliminates any duplicates in the list.


#### Query the outputs

Run the `terraform output` command to see the output values.  Also query some of the outputs individually.

```console
$ terraform output
My_Bucket_Name = "zippy-the-wonder-llama-9989"
SSH_Keys = toset([
  "r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af",
])
VM_Profile = "bx2-2x8"

$ terraform output VM_Profile
"bx2-2x8"
```

## String Interpolation

Use string interpolation to create some descriptive strings for the outputs.

A sample file that does this is in `interpolate.tf`

Disable the file `outputs.tf` by renaming it to `outputs.tf.old` and add the `interpolate.tf` file.

```terraform
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

```

The `SSH_Keys` syntax needs some explanation. String interpolation only works on strings, and the value of the variable is a set. We have to convert the set to a list using `tolist()` in order to access the first element or `[0]` 

Run `terraform apply` and note that Terraform will only change the outputs, not any of the infrastructure.


```console
Changes to Outputs:
  + My_Bucket_Name = "The name of my Object Bucket is zippy-the-wonder-llama-9989 "
  + SSH_Keys       = "This r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af is the ssh key my VM uses"
  + VM_Profile     = "The CM profile used in my VM is !{ibm_is_instance.my_vm.profile} "

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Outputs:

My_Bucket_Name = "The name of my Object Bucket is zippy-the-wonder-llama-9989 "
SSH_Keys = "This r006-1c9c4042-4aed-4afe-b811-fd0b0905a4af is the ssh key my VM uses"
VM_Profile = "The CM profile used in my VM is !{ibm_is_instance.my_vm.profile} "
```

## Clean up

Run `terraform destroy` to clean up all the resources used in this lab and confirm at the console that they have been destroyed.

---

## End Lab