# Lab IBM 4 - Terraform Variable Directives

##### Working with Terraform variables

---

## Objectives

In this lab, you will configure a Terraform deployment using variables.

## Setup

This lab uses the code from the last lab except for the `interpolate.tf`. 

Start by copying all the `*tf` files from the previous lab except for the `interpolate.tf` file.

## Coding

#### Defining the variables

Start by adding a `variables.tf` file that defines some Terraform variables

```terraform
variable "res_group" {
    description = "Resource group for this lab"
    type = string
     default = "Anonymous"
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

variable "bucket_name" {
    description = "Name for the object bucket"
    type = string
    default = "puppies-wearing-boots-77333"
}
```

#### Replace hard coded values

In the `compute.tf` file, add the variable references

```terraform
resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image
  resource_group = ibm_resource_group.my_rg.id

  profile = var.vm_profile
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
```

In the `bucket.tf'` file

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
  bucket_name          = var.bucket_name
  resource_instance_id = ibm_resource_instance.my_cos.id
  region_location      = "us-south"
  storage_class        = "standard"
}
```
And finally, in the `resource_group.tf` file

```terraform
resource "ibm_resource_group" "my_rg" {
  name = var.res_group
}
```

#### Outputs

Add a set of outputs to confirm that the variable values are being used. Add a file `outputs.tf` which contains

```terraform
output "EC2_Ami" {
  description = "The aim of my_vm"
  value       = aws_instance.my_ec2.ami
}
output "EC2_Instance" {
  description = "The instance tyoe of my_vm"
  value       = aws_instance.my_ec2.instance_type
}

output "S3_ARN" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}
```

#### Define the variables

Create a file named `terraform.tfvars` which contains the following:

```terraform
vm_image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
vm_profile = "bx2-2x8"
bucket_name = "zorgo-the-magic-asp-111"
res_group = "Lab4"
```

#### Implement the configuration

Validate with `terraform validate`. Then use `terraform apply` to implement the configuration.

Pay particular attention to the outputs


```console
Outputs:

My_Bucket_Name = "zorgo-the-magic-asp-111"
My_Resource_Name = "Lab4"
VM_Image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
VM_Profile = "bx2-2x8"
```

## Experiment 

#### Default values

Comment out the `vm_image` and `bucket_name` variables in the `terraform.tfvars` file and rerun `terraform apply`

Notice the values of these variables in the output and confirm that they are the same as the default value in the `variables.tf` file

```console
utputs:

My_Bucket_Name = "default-name-for-bucket-77333"
My_Resource_Name = "Lab4"
VM_Image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
VM_Profile = "bx2-2x8"
```

#### Command line prompting

Comment out the `VM_Profile` line in the `terraform.tfvars` file and rerun `terraform apply`

Note that you will be prompted at the command line for a value. Enter `bx2-2x8` and hit return

```console
$ terraform apply
var.vm_profile
  Profile used for vm

  Enter a value: bx2-2x8  
  
 Outputs:

My_Bucket_Name = "default-name-for-bucket-77333"
My_Resource_Name = "Lab4"
VM_Image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
VM_Profile = "bx2-2x8"
```

## Clean up

Run `terraform destroy` and confirm the resources have been deleted.

---
 
## End Lab