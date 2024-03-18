# Lab AWS 6 - Count

##### Creating multiple resources

---

## Set up

Set up your provider configuration file `providers.tf` and initialize terraform

---

## Create the VM 

Note that the lab code provided uses variables but you can hard code the VM parameters if you find it more convenient.

```terraform
resource "aws_instance" "my_ec2" {
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "Lab 6 VM" 
  }
}
```

With the `variables.tf` file

```terraform
variable "ami_type" {
  description = "The ami type to be used for the VM"
  type        = string
  default     = "ami-0f403e3180720dd7e"
}

variable "inst_type" {
  description = "Instance type for the VM"
  type        = string
}
```

And the `terraform.tfvars` file

```terraform
ami_type = "ami-080e1f13689e07408"
inst_type = "t2.nano"
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

In order to ensure we create exactly the same number of VMs as there are owners, we set the upper limit of `count` to the length of the list of owners. The name of the VM will include the owner

```terrform
resource "aws_instance" "my_ec2" {
  count = length(var.owners)
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "VM-${count.index} ${var.owners[count.index]}"
  }
}
```

Confirm in the console that you have three VMs running.

Now add a couple of output variables to check on the states of the machines

```terraform
output  "Neo" {
    value = aws_instance.my_ec2[0].tags.Name
    description = "Outputs a single string"
}
output  "Everyone" {
    value = aws_instance.my_ec2[*].tags.Name
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
        "VM-0 Neo",
      - "VM-1 Trinity",
      - "VM-2 Morpheus",
      + "VM-1 Morpheus",
    ]
```

Notice that the second VM is not destroyed, the last one "VM-2 Morpheus" is, then the second machine is renamed from "VM-1 Trinity" to "VM-1 Morpheus" Can you explain why?

Note the IDs of the VMs in the console, then run `terraform apply` and re-examine the IDs in the console to confirm what happened.

## Clean up

Run `terraform destroy` to spin down the configuration

## End Lab