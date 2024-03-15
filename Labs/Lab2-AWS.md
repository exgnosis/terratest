# Lab AWS 2 - Terraform Resource Directives

##### Working with resource directives

---

## Objectives

In this lab, you will create a object bucket and a VM.

Do not delete your code when you are done, you will be adding to it in the next several labs.

## Step One - Creating an AWS bucket

#### Documentation

To see what sort of attributes we need to create a bucket, refer to the documentation [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

Notice that there are no required arguments and all the values needed to create the bucket can be optionally supplied by AWS.

#### Terraform Code

First, create the `providers.tf` file

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

Now create two buckets. The first has some of the arguments specified in the Terraform code.

Do not use the name of the bucket shown here. The name must be unique across the the known universe and all parallel dimensions. Generally it is safe to use some nonsensical phrase with just lower case letters, hyphens and some random digits.

```terraform
resource "aws_s3_bucket" "my_bucket" {
  bucket = "zippy-the-wonder-llama-8879"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# This bucket will be created with all the defaults
resource "aws_s3_bucket" "my_default_bucket" {
}

```

#### Plan and Apply

Run the `validate` and `plan` commands.

Note that some of the properties of the bucket will be known after the bucket is created.

```console
 # aws_s3_bucket.my_default_bucket will be created
  + resource "aws_s3_bucket" "my_default_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
```

Run the `apply` command and note Terraform returns the ids of the two buckets.

```console
aws_s3_bucket.my_default_bucket: Creating...
aws_s3_bucket.my_bucket: Creating...
aws_s3_bucket.my_default_bucket: Creation complete after 2s [id=terraform-20240315171041840900000001]
aws_s3_bucket.my_bucket: Creation complete after 3s [id=zippy-the-wonder-llama-8879]
```

Confirm the existence of the buckets at the console

![](images/twoawsbuckets.png?raw=true)

#### Destroy and rename the file

Destroy the buckets using the `destroy` command. Confirm that they have been destroyed.

Now rename the file `bucket.tf` to `bucket.tf.old` so that you won't constantly be creating and destroying the buckets for the rest of the lab.

Run `terraform plan` to confirm that nothing needs to be done.

```console
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed
```

## Step Two - VM Creation

#### Review Documentation

The documentation for the Terraform EC2 instance is [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

Notice that two arguments are required unless a launch template is provided, which we are not doing.

These are the `ami` which is the image type that specifies the operating system. And the `instance_type` that specifies the size and capacity of the VM.

#### Create and inspect the VM

Create a new file called `ec2.tf` with the following code.

```terraform
resource "aws_instance" "my_ec2" {
 ami           = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
    lab = "lab2"
  }
}
```

Create the VM using Terraform and then confirm by using the console just like you did with the previous section.

##### Change the instance type

Change the `ec2.tf` to change the instance type to `t2.nano`

```terraform
resource "aws_instance" "my_ec2" {
 ami           = "ami-0f403e3180720dd7e"
  instance_type = "t2.nano"

  tags = {
    Name = "Terraform"
    lab = "lab2"
  }
}
```
Now run `terraform plan` and see what changes Terraform would make. Because this is just a reallocation of physical resources, the change can be done without shutting down the machine.

```console
Terraform will perform the following actions:

  # aws_instance.my_ec2 will be updated in-place
  ~ resource "aws_instance" "my_ec2" {
        id                                   = "i-097c6788d68ce9db9"
      ~ instance_type                        = "t2.micro" -> "t2.nano"
        tags                                 = {
            "Name" = "Terraform"
            "lab"  = "lab2"
        }
        # (27 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Now change the ami to a new value `ami-07d9b9ddc6cd8dd30` and change the instance type back to `t2.micro. In this case, running `terraform plan` shows that the machine will have to be replace since the image cannot be updated in place since it represents switching operating systems.

```terraform
resource "aws_instance" "my_ec2" {

 ami = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
    lab = "lab2"
  }
}
```

```console
  # aws_instance.my_ec2 must be replaced
-/+ resource "aws_instance" "my_ec2" {
      ~ ami                                  = "ami-0f403e3180720dd7e" -> "ami-07d9b9ddc6cd8dd30" # forces replacement
      ~ arn                                  = "arn:aws:ec2:us-east-1:983803453537:instance/i-097c6788d68ce9db9" -> (known after apply)
      ~ associate_public_ip_address          = true -> (known after apply)
      ~ availability_zone                    = "us-east-1c" -> (known after apply)
      ~ cpu_core_count                       = 1 -> (known after apply)
      ~ cpu_threads_per_core 
```

Now remove the `ami` argument entirely and run `terraform validate` and notice that Terraform picks up the error.

```console

│ Error: Missing required argument
│ 
│   with aws_instance.my_ec2,
│   on ec2.tf line 1, in resource "aws_instance" "my_ec2":
│    1: resource "aws_instance" "my_ec2" {
│ 
│ "ami": one of `ami,launch_template` must be specified
╵
```

#### Shut down and save

Use `terraform destroy` to remove teh VM. Confirm at the console that the VM is terminated. Revert the file to the original `ami` and `instance_type` and save.

Keep your code, you will use it in the next lab.

---

## End Lab