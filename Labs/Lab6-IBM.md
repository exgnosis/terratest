# Lab IBM 6 - Count

##### Creating multiple resources

---

## Set up

Set up your provider configuration file `providers.tf` and initialize terraform

---

## Create the VM, resource group and network resoures

Note that the lab code provided uses variables but you can hard code the VM parameters if you find it more convenient.

In the `resource_grou.tf` file

```terraform
resource "ibm_resource_group" "my_rg" {
  name = var.res_group
}
```

In the `sshkeys.tf` file

```terraform
resource "ibm_is_ssh_key" "my_ssh_key" {
  resource_group = ibm_resource_group.my_rg.id
  name       = "lab2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
  type       = "rsa"
}
```

In the `network.tf` file

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

In the `variables.tf` file

```terraform
variable "res_group" {
    description = "Resource group for this lab"
    type = string
}

variable "vm_image" {
    description = "Image used for vm"
    type = string
    default = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
}

variable "vm_profile" {
    description = "Profile used for vm"
    type = string
}
```

And finally, the `terraform.tfvars` file

```terraform
vm_image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
vm_profile = "bx2-2x8"
res_group = "Lab6"
```


Spin up the VM with `terraform apply` to ensure that it deploys properly, then shut it down with `terraform destroy`

--- 

## Add the list of VM owners

In the `variables.tf` file, add the following variable

```terraform
variable "owners" {
  description = "Instance type for the VM"
  type        = list(string)
}
```

In the `terraform.tfvars` file, add three owners

```terraform
owners = ["Neo", "Trinity", "Morpheus"]
```

## Set up count

In order to ensure we create exactly the same number of VMs as there are owners, we set the upper limit of `count` to the length of the list of owners. The tags will include the number of the VM and the name of the owner

```terrform
resource "ibm_is_instance" "my_vm" {
count = length(var.owners)
  name    = "myvm${count.index}"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image
  resource_group = ibm_resource_group.my_rg.id
  tags = ["VM ${count.index}","${var.owners[count.index]}"]
 
  profile = var.vm_profile
 

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}

```

Confirm in the console that you have three VMs running.

Now add a couple of output variables to check on the states of the machines

```terraform
output  "Neo" {
    value = ibm_is_instance.my_vm[0].tags
    description = "Outputs a single string"
}
output  "Everyone" {
    value =ibm_is_instance.my_vm[*].tags
    description = "Outputs a list of strings"
}
```

And run `terraform apply` to see the values

```console
Outputs:

Everyone = [
  "VM-0 Neo",
  "VM-1 Trinity",
  "VM-2 Morpheus",
]
Neo = "VM-0 Neo"
```

Note: If you get validation errors on the output file before you run apply the first time, it's because Terraform cannot predict that it will have a list of machines. If this happens, add the `outputs.tf` file after you run apply the first time.

## Reallocation

For this remove "Trinity" from the list of owners. then run `terraform plan` to see what changes are would be made.

```console
Changes to Outputs:
  ~ Everyone = [
        [
            "neo",
            "vm 0",
        ],
      - [
          - "trinity",
          - "vm 1",
        ],
      - [
          - "morpheus",
          - "vm 2",
        ],
      + [
          + "Morpheus",
          + "VM 1",
        ],
    ]

```

Notice that the second VM is not destroyed, the last one "VM-2 Morpheus" is, then the second machine is renamed from "VM-1 Trinity" to "VM-1 Morpheus" Can you explain why?

Note the IDs of the VMs in the console, then run `terraform apply` and re-examine the IDs in the console to confirm what happened.

## Clean Up

Run `terraform destroy` to spin down your resources. Check at the console to ensure they are destroyed.

## End Lab