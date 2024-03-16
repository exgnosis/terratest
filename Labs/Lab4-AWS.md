# Lab AWS 4 - Terraform Variable Directives

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
variable "ami_type" {
  description = "The ami type to be used for the VM"
  type        = string
  default     = "ami-0f403e3180720dd7e"
}

variable "inst_type" {
    description = "Instance type for the VM"
    type = string
}

variable "bucket_name" {
    description = "Name of the bucket to be created"
    type = string
}
```

#### Replace hard coded values

In the `ec2.tf` file, add the variable reference

```terraform
resource "aws_instance" "my_ec2" {
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "Terraform"
    lab  = "lab4"
  }
}
```

And the `bucket.tf'` file

```terraform
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
    Name        = "My bucket"
    Environment = "Lab 4"
  }
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
ami_type = "ami-080e1f13689e07408"
inst_type = "t2.nano"
bucket_name = "fried-onion-snacks-9987"
```

#### Implement the configuration

Validate with `terraform validate`. Then use `terraform apply` to implement the configuration.

Pay particular attention to the outputs


```console
Outputs:

EC2_Ami = "ami-080e1f13689e07408"
EC2_Instance = "t2.nano"
S3_ARN = "arn:aws:s3:::fried-onion-snacks-9987"
```

## Experiment 

#### Default values

Comment out the `ami_type` variable in the `terraform.tfvars` file and rerun `terraform apply`

Notice the value of the `ami` in the output and confirm that it is the same as the default value in the `variables.tf` file

```console
Outputs:

EC2_Ami = "ami-0f403e3180720dd7e"
EC2_Instance = "t2.nano"
S3_ARN = "arn:aws:s3:::fried-onion-snacks-9987"
```

#### Command line prompting

Comment out the `inst_type` line in the `terraform.tfvars` file and rerun `terraform apply`

Note that you will be prompted at the command line for a value. Enter `t2.medium` and hit return

```console
$ terraform apply
var.inst_type
  Instance type for the VM

  Enter a value: t2.medium
  
  Outputs:

EC2_Ami = "ami-0f403e3180720dd7e"
EC2_Instance = "t2.medium"
S3_ARN = "arn:aws:s3:::fried-onion-snacks-9987"
```

## Clean up

Run `terraform destroy` and confirm the resources have been deleted.

---
 
## End Lab