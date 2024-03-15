# Lab AWS 3 - Terraform Output Directives

##### Working with output directives

---

## Objectives

In this lab, you will create some outputs to add to the code from the previous lab.

## Setup

Create a new directory and add the code from lab 2. Make sure that you change the name of the `bucket.tf` file has the disabling extension you added in the last lab removed so that it can be executed by `terraform apply`.

The `providers.tf` file should look something like this.

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

The `bucket.tf` code should look like this.

```terraform 
resource "aws_s3_bucket" "my_bucket" {
  bucket = "zippy-the-wonder-llama-8879"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

And the `ec2.tf` file should look something like this.

```terraform
resource "aws_instance" "my_ec2" {
 ami           = "ami-0f403e3180720dd7e"
 #ami = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
 #instance_type = "t2.nano"

  tags = {
    Name = "Terraform"
    lab = "lab3"
  }
}
```

Create a file called `network.tf` which queries the default VPC and looks like this

```terraform
data "aws_vpc" "default_vpc" {
    default = true
}
```

#### Run the application

Run Terraform to deploy the application and confirm the resources have been created

## Add the outputs

Add a new file called `outputs.tf` that looks like this:

```terraform 
output "EC2_Public_IP" {
    description = "The public IP address of my_vm"
    value = aws_instance.my_ec2.public_ip
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = data.aws_vpc.default_vpc.id    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = aws_s3_bucket.my_bucket.arn
}
```

Rerun `terraform apply`. Notice that the only change that Terraform makes is to produce the output file.

```console
Changes to Outputs:
  + EC2_Public_IP = "52.90.141.249"
  + S3_ARN        = "arn:aws:s3:::zippy-the-wonder-llama-8879"
  + VPC_id        = "vpc-43898f39"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
```

#### Query the outputs

Run the `terraform output` command to see the output values.  Also query some of the outputs individually.

```console
$ terraform output
EC2_Public_IP = "52.90.141.249"
S3_ARN = "arn:aws:s3:::zippy-the-wonder-llama-8879"
VPC_id = "vpc-43898f39"

terraform output S3_ARN
"arn:aws:s3:::zippy-the-wonder-llama-8879"
```

## String Interpolation

Use string interpolation to create some descriptive strings for the outputs.

A sample file that does this is in `interpolate.tf` 

Disable the file `outputs.tf` by renaming it to `outputs.tf.old` and add the `interpolate.tf` file.

```terraform
output "EC2_Public_IP" {
    description = "The public IP address of my_ec2"
    value = "The public id of my vm is ${aws_instance.my_ec2.public_ip} "
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = "${data.aws_vpc.default_vpc.id} is the id of the default VPC"    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = "${aws_s3_bucket.my_bucket.arn} is the arn of the bucket ${aws_s3_bucket.my_bucket.bucket}"
}
```

Run `terraform apply` and note that Terraform will only change the outputs, not any of the infrastructure.


```console
Changes to Outputs:
  ~ EC2_Public_IP = "52.90.141.249" -> "The public id of my vm is 52.90.141.249 "
  ~ S3_ARN        = "arn:aws:s3:::zippy-the-wonder-llama-8879" -> "arn:aws:s3:::zippy-the-wonder-llama-8879 is the arn of the bucket zippy-the-wonder-llama-8879"
  ~ VPC_id        = "vpc-43898f39" -> "vpc-43898f39 is the id of the default VPC"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

EC2_Public_IP = "The public id of my vm is 52.90.141.249 "
S3_ARN = "arn:aws:s3:::zippy-the-wonder-llama-8879 is the arn of the bucket zippy-the-wonder-llama-8879"
VPC_id = "vpc-43898f39 is the id of the default VPC"
```

## Clean up

Run `terraform destroy` to clean up all the resources used in this lab

---
 
## End Lab