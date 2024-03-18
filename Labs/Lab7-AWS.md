
# Lab AWS 7 - Modules

## Part 1

---

### Setup

Create a directory structure that looks like this

![](images/lab7-1.png?raw=true)

The `project` directory is your root module. Whenever you run any Terraform command, it must be from this directory.

### Module Code

In the module file, you can add the code to create an EC2 instance. Use any file name you want but in this lab the name `ec2.tf` is being used. _Do not put any sort pf providers information in this module.

Starting code in `ec2.tf` should look like:

```terraform
resource "aws_instance" "alpha" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.nano"
    tags = {
        source = "EC2 Module"
    }
}
```

### Root Module Code

In the `project` directory, add the `providers.tf` file

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```
And the code to call the module in `main.tf`  

Notice the module resource name is `"vm"`

```terraform
module "vm" {
    source = "../modules/EC2"
}
```

### Deploy

Run `terraform init` from the `project` directory. Note that the module is also initialized as part of the overall Terraform application

```console
$ terraform init

Initializing the backend...
Initializing modules...
- vm in ../modules/EC2

```

Run `terraform validate` the `terriform apply` to deploy

Check the console to make sure that the vm is deployed.

### Clean up

Run `terraform destroy` to spin down the deployment and confirm at the console

---

## 3 Part Two - Parameterize the Module

First, create the `variables.tf` file in the EC2 module. 

```terraform

variable "ami_type" {
    type = string
    default = "ami-080e1f13689e07408"
}

variable "inst_type" {
    type = string
    default = "t2.nano"
}

variable VM_name {
    type = string
    default = "EC2-Module"
}
```

And parameterize the `ec2.tf` file

```terraform
resource "aws_instance" "alpha" {
    ami = var.ami_type
    instance_type = var.inst_type
    tags = {
        source = "EC2 Module"
        Name = var.VM_name
    }
}
```
Now in the `main.tf` file in the root module, call the EC2 module twice with different parameters

```terraform
module "vm1" {
    source = "../modules/EC2"
    ami_type = "ami-0d7a109bf30624c99"
    inst_type = "t2.medium"
    VM_name = "VM-1"

}

module "vm2" {
    source = "../modules/EC2"
    inst_type = "t2.micro"
    VM_name = "VM-2"
}

module "vm3" {
    source = "../modules/EC2"
    VM_name = "VM-3"
  }
```

Run `terraform init`  and then use the Terraform commands to confirm the deployment.

Confirm at the console that the three VMs are running

Then run 'terraform destroy' to spin down your deployment.

## Part 3 - Parameterized Application

For the final step add a `varables.tf` file in the `project` directory that looks like this
```terraform
variable "amis" {
    type = list(string)
}

variable "insts" {
    type = list(string)
   
}

variable names {
    type = list(string)
}
```

With a `terraform.tfvars` in the project directory that looks like this:

```terraform
amis = ["ami-080e1f13689e07408","ami-080e1f13689e07408","ami-0d7a109bf30624c99"]
insts = ["t2.nano", "t2.nano", "t2.micro"]
names = ["Frodo", "Gandalf", "Gollum"]
```

Now parameterize the function calls in the root module in the `main.tf` file

```terraform

module "vm1" {
    source = "../modules/EC2"
    ami_type = var.amis[0]
    inst_type = var.insts[0]
    VM_name = var.names[0]

}

module "vm2" {
    source = "../modules/EC2"
    ami_type = var.amis[1]
    inst_type = var.insts[1]
    VM_name = var.names[1]

}

module "vm3" {
    source = "../modules/EC2"
     ami_type = var.amis[2]
    inst_type = var.insts[2]
    VM_name = var.names[2]

  }
```

Run `terraform validate` and then `terraform apply`

Confirm at the console that the three VMs are up and running with the correct attributes.

## Clean up

Run `terraform destroy` to spin down your configuration and confirm at the console that is has been destroyed.


## End Lab

