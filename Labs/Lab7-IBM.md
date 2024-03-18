
# Lab IBM 7 - Modules


## Part 1

---

### Setup

Create a directory structure that looks like this

![](images/lab7-1-ibm.png?raw=true)

The `project` directory is your root module. Whenever you run any Terraform command, it must be from this directory.

### Module Code

In the module `vm`, add the code to create the VM and its dependencies except for the resource group, we will just use the default group.

It is important to note that we have to have all the resources with dependencies on each other in the same module. Ideally, we would like to have, for example, the `sshkeys.tf` code in its own module. At this point, we have not yet covered how to communicate between modules, so that will be deferred until a later lab.

The files are `sshkeys.tf`

```terraform
resource "ibm_is_ssh_key" "my_ssh_key" {
  name       = "lab2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
  type       = "rsa"
}
```

And `network.tf`

```terraform
resource "ibm_is_vpc" "my_vpc" {
  name = "myvpc"
}

resource "ibm_is_subnet" "my_subnet" {
  name            = "mysubnet"
  vpc             = ibm_is_vpc.my_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}
```
And the `compute.tf` file:

```terraform
resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image


  profile = var.vm_profile
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}

```

#### Module provider

**Important**

Unlike AWS, each module must have a provider file for IBM modules. So make sure you put a copy of `providers.tf` in the module as well as in the root module


### Root Module Code

In the `project` directory, add the `providers.tf` file

```terraform
tterraform {
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
And the code to call the module in `main.tf`

Notice the module resource name is `"vm"`

```terraform

module "vm" {
    source = "../modules/vm"
}

```

### Deploy

Run `terraform init` from the `project` directory. Note that the module is also initialized as part of the overall Terraform application

```console
$ terraform init

Initializing the backend...
Initializing modules...

Initializing provider plugins...
- Reusing previous version of ibm-cloud/ibm from the dependency lock file
- Using previously-installed ibm-cloud/ibm v1.63.0

Terraform has been successfully initialized!
```

Run `terraform validate` the `terriform apply` to deploy

Check the console to make sure that the vm is deployed.

### Clean up

Run `terraform destroy` to spin down the deployment and confirm at the console

---

##  Part Two - Parameterize the Module

In the `vm` module, add the following `variables.tf` file

```terraform
variable "vm_image" {
    description = "Image used for vm"
    type = string
}

variable "vm_profile" {
    description = "Profile used for vm"
    type = string
}
```

And parameterize the `compute.tf` file

```terraform
resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = var.vm_image
  tags = ["source:vm module"]


profile = var.vm_profile
  

  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
  }

  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
```

In the root module in the `project` directory, call the `vm` module with arguments

```terraform
module "vm" {
    source = "../modules/vm"
    vm_image = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
    vm_profile = "bx2-2x8"
}
```

In the `project` directory, run `terraform plan` to see what will be made. Then run 1terraform apply`.

Confirm at the console that the deployment is up and running. Then use `terraform destroy` to spin down the deployment.

---

## Part Three - Multiple Module Calls

In the `project/main.tf` file, add a second module call.

```terraform
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
```

Rerun 'terraform init' since the new module call needs to be tracked. If your run `terraform plan` it does look like this is deployable

However, when you run `terraform apply` an error like this will appear

```console
 Error: [ERROR] Error while creating VPC {
│     "Message": "Provided Name (myvpc) is not unique",
│     "StatusCode": 400,
│     "Result": {
│         "errors": [
│             {
│                 "code": "validation_unique_failed",
│                 "message": "Provided Name (myvpc) is not unique",
│                 "target": {
│                     "name": "vpc",
│                     "type": "field"
│                 }
│             }
│         ],
│         "trace": "d455151d-5101-4092-8a88-1ce1837f0792"
│     }
│ }
```
This is happening because each time we call the `vm` module, we are creating a VPC but each ot the two VPCs has the same name. That is not allowed.

The two solutions are:

1. Parameterize everything in the module. The problem is that every module will be creating duplicate sets of resources. And it involves a LOT of code.

2. Put each resource in its own module and call them individually. This is the way we will do in upcoming labs.

Run `terraform destory` to spin down the deployment and confirm that all the resources have been destroyed.

---

## Part Three - Parameterizing the Application

We still have some hard coded values.  In the `project` directory, create a `variables.tf` file which looks like this.

```terraform
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

And a `terraform.tfvars` file that looks like this

```terraform
vm_image = "r006-f259b449-f3d4-4924-8d67-61201f728068"
vm_profile = "bx2-2x8"
```

Now use the variables in the module call in `main.tf`

```terraform
module "vm" {
    source = "../modules/vm"
    vm_image = var.vm_image
    vm_profile = var.vm_profile
}
```

Even though the variable names are the same in the root and vm module, the use of the prefix `var.` ensure Terraform knows that is the variable defined in the root module, and the variable name on the left hand side of the equal sign does not have a `var.` prefix which means it's the one in the vm module.

Run `terraform init` to initialize the modules then run the Terraform commands to deploy the configuration.

## Clean Up

Once you have confirmed that the deployment is running correctly at the console, then run `terraform destroy` to spin down the resources.

## End Lab

## End Lab