# Lab AWS 5 - Local and *.auto.tfvars

##### More Terraform variables

---

## Objectives

In this lab, you will continue to configure the Terraform deployment from the previous lab.

## Set up

Copy the code from the previous lab and run `terraform init` and `terraform validate` to ensure it is ready to go.

#### Set up the tags

In the first part, we want to set up some consistent tagging. We will assume that all the artifacts must be tagged with a `team` tag, a `source` tag that identifies how they were created and a `lab` tag that defines these to belong to _Lab 5_.

``` terraform
resource "aws_instance" "my_ec2" {
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "Lab 5 VM"
    team = Dev team 1"
    source = "Terraform"
    lab = "Lab 5"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Work Bucket"
    team = Dev team 1"
    source = "Terraform"
    lab = "Lab 5"
  }
}
```

Run `terraform validate` to catch any errors (note: one of the most common errors that gets caught in validate is mismatched quotes), then run `terraform apply`

Check to ensure that all the tags are properly applied. Then run `terraform destroy`. 

## Part One - Local Variables

Create a file called `locals.tf` Keeping the local variable definitions in their own file makes it easier to replace them with a different set.

```terraform
locals {
    team = "Dev Team 1"
    source = "Terraform"
    lab = "Lab 5"
}
```

Replace the hardcoded tag values

```terraform
resource "aws_instance" "my_ec2" {
  instance_type = var.inst_type
  ami           = var.ami_type

  tags = {
    Name = "Lab 5 VM"
    team = local.team
    source = local.source
    lab = local.lab
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Work Bucket"
   team = local.team
    source = local.source
    lab = local.lab
  }
}
```
Run `terraform validate` to catch any errors, then run `terraform apply`

Check to ensure that all the tags are properly applied. Then run `terraform destroy`. 

## Part Two - Overriding variables

The `terraform.tfvars` file should look like this:

```terraform
ami_type = "ami-080e1f13689e07408"
inst_type = "t2.nano"
bucket_name = "fried-onion-snacks-9987"
```

Add a new override file called `dev.auto.tfvars` which overrides the instance and the bucket name

```terraform
inst_type = "t2.micro"
bucket_name = "dev-version-snacks-9987"
```

Run `terraform plan` to see the changes, then run `terraform apply` to see the `dev.auto.rfvars` file has overridden the values in the `terraform.tfvars` file

```console
Outputs:

EC2_Ami = "ami-080e1f13689e07408"
EC2_Instance = "t2.micro"
S3_ARN = "arn:aws:s3:::dev-version-snacks-9987"
```

Confirm at the console that the values are in fact changed.

Now add another file `test.auto.tfvars` that overrides the name of the bucket like this:

```terraform
bucket_name = "test-team-version-snacks-9987"
```

Run `terraform plan` to see the changes, then run `terraform apply` to see the `dev.auto.rfvars` file has overridden the values in the `terraform.tfvars` file and the `dev.auto.tfvars` file

Now run `terriform apply` to see the change and confirm the values at the console.

```console
Outputs:

EC2_Ami = "ami-080e1f13689e07408"
EC2_Instance = "t2.micro"
S3_ARN = "arn:aws:s3:::test-team-version-snacks-9987"
```

## Clean up

Run `terraform destroy` and confirm the resources are destroyed

---

## End Lab