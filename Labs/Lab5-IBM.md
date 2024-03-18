# Lab IBM 5 - Local and *.auto.tfvars

##### More Terraform variables

---

## Objectives

In this lab, you will continue to configure the Terraform deployment from the previous lab.

## Set up

Copy the code from the previous lab and run `terraform init` and `terraform validate` to ensure it is ready to go.

#### Set up the tags

In the first part, we want to set up some consistent tagging. We will assume that all the artifacts must be tagged with a `team` tag, a `source` tag that identifies how they were created and a `lab` tag that defines these to belong to _Lab 5_.

Each of the resources we are tagging are demonstrated below. These files are also available in the `Lab5/IBM-Start` directory

First the resource group:

```terraform

resource "ibm_resource_group" "my_rg" {
  name = var.res_group
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]
}
```

Next the network

```terraform
resource "ibm_is_vpc" "my_vpc" {
  name = "myvpc"
  resource_group = ibm_resource_group.my_rg.id
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]
}
```

And the ssh keys
```terraform
resource "ibm_is_ssh_key" "my_ssh_key" {
  resource_group = ibm_resource_group.my_rg.id
  name       = "lab2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
  type       = "rsa"
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]
}
```

And the COS service 

```terraform
resource "ibm_resource_instance" "my_cos" {
  name              = "mycos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = ibm_resource_group.my_rg.id
  tags              = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]
}
```
 And the compute resource

```terraform
esource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image
  resource_group = ibm_resource_group.my_rg.id
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]

  profile = var.vm_profile
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
```
Once you have tagged the resources, run `terraform validate` to confirm the syntax is correct and then run `terraform apply` and check the tags in the console. Once you have confirmed this, use `terraform destroy` to spin down the deployment.

Add a new file called `locals.tf` with the following content

```terraform
locals {
    team = "team:dev team 1"
    source = "source:terraform"
    lab ="lab:Lab 5"
}
```

For each resource that was tagged, replace the hardcoded tags with local variables so that they all look like this.

```terraform
resource "ibm_resource_group" "my_rg" {
  name = var.res_group
 tags   = [local.source, local.lab, local.team]
}
```

Once that is done, runt `terraform validate` to pick up any typos, and then run `terraform apply` and confirm the resources are tagged correctly at the console. You can leave your deployment up for the next section

## Part Two - *.auto.tfvars files

The current `terraform.tfvars` file looks like this

```terraform
vm_image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
vm_profile = "bx2-2x8"
bucket_name = "zorgo-the-magic-asp-222"
res_group = "Lab5"
```

Create a new file called `dev.auto.tfvars` with the following content

```terraform
vm_image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
bucket_name = "dev-zorgo-the-magic-asp-222"
```
## End Lab

First check the output of the current deployment

```console
Outputs:

My_Bucket_Name = "zorgo-the-magic-asp-222"
My_Resource_Name = "Lab5"
VM_Image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
VM_Profile = "bx2-2x8"

```

Run `terraform validate` and then `terraform apply` Notice how the values in this file have overwritten the corresponding values in `terraform.tfvars`

```console
Outputs:

My_Bucket_Name = "dev-zorgo-the-magic-asp-222"
My_Resource_Name = "Lab5"
VM_Image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
VM_Profile = "bx2-2x8"
```

Now add another file called `testing.auto.tfvars` with the following content

```terraform
bucket_name = "testing-zorgo-the-magic-asp-222"
```

Run `terraform apply` again and notice how this file overwrite the `dev.auto.tfvars` file.

```console

Outputs:

My_Bucket_Name = "testing-zorgo-the-magic-asp-222"
My_Resource_Name = "Lab5"
VM_Image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
VM_Profile = "bx2-2x8"
```

---

## Clean up

Use `terraform destroy` to delete your created resources.

---

## End Lab

