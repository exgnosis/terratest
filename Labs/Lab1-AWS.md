# Lab AWS 1 - Terraform workflow

##### Managing an AWS EC2 instance

---

## Objectives

In this lab, you will create, explore the Terraform workflow by creating, modifying and destroying an AWS EC2 instance/

### Setup 

For this lab, will want to use the AWS console so that your can check your work.

The lab assumes that you have created an AWS profile that has your api key created from the set-up lab

This lab uses _us-east-1_ and the region, but you can use another region if you want to avoid us-east-1, for example, if you are already using it for some specific projects.

## Step One - Create the resource

### Check existing EC2

Log into the AWS console and go to the _us-east-1_ region and the _EC2 Service_ and check to see what EC2 instances are currently in existence. 

![](images/lab1-1_aws.png?rAW=TRUE)

`
### Create the providers file

Create a file called `providers.tf` which looks like this:

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
### Initialize Terraform

This provider block can npw be used by `terraform init` to download and install the AWS Cloud plug in.

```console
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.76.1...
- Installed hashicorp/aws v3.76.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

```

### Adding the configuration code

Create a new file called `main.tf`, or whatever else you want as long as it has the `.tf` extension. 

Add the following code to it.

```terraform
resource "aws_instance" "my_rc2_instance" {
  ami           = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
  }
}
```
 The keyword _resource_ tells Terraform that this is a resource description. The _"aws_instance"_ string identifies which AWS cloud resource type this specification refers to.
 
The string "my_rc2_instance" is the local name by which we can refer to this resource _in the Terraform code,_ it is not communicated in any way to the AWS cloud. 

Inside the braces are the parameters that the cloud needs to instantiate this resource. In the case of the EC2 instance, we need to specify the ami image (operating system) and the instance type which describes the physical properties of the VM like cpus, memory, etc.

There is one optional parameter which is the Name tag.

### Validate the code

The validator is a lightweight syntax checker that ensures your Terraform code is syntactically correct _before_ contacting the cloud provider.

Run the validator as shown. If you have written the code correctly, then it should pass.

```console
$terraform validate
Success! The configuration is valid.
```
Now invalidate the code by commenting out the ami parameter.

```terraform
resource "aws_instance" "my_rc2_instance" {
 # ami           = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
  }
}
```

Run validate again and the error is picked up because the plugin has a description of what parameters are required for a particular resource

```console
$ terraform validate
╷
│ Error: Missing required argument
│ 
│   with aws_instance.my_rc2_instance,
│   on main.tf line 1, in resource "aws_instance" "my_rc2_instance":
│    1: resource "aws_instance" "my_rc2_instance" {
│ 
│ "ami": one of `ami,launch_template` must be specified
```
Uncomment out the line you commented out and run validate again to confirm your code is valid

### Plan the deployment

Running `terraform plan` will do several things.  

First it will query the provider to see what already may have been deployed by terraform earlier. It then compares this information to the configuration described in your `*.tf` files.

It then creates a DAG to figure out what needs to be created, what needs to modified and what needs to be deleted in the cloud to make the existing deployment conform to the one you specified.

```console
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.my_rc2_instance will be created
  + resource "aws_instance" "my_rc2_instance" {
      + ami                                  = "ami-0f403e3180720dd7e"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "Terraform"
        }
      + tags_all                             = {
          + "Name" = "Terraform"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
 The `terraform plan` command doesn't make any changes, it just tells you what it will do.

Notice that only the _ami_ and _instance_type_ parameters have a value. All the others are optional or set when the resource is created. The EC2 instance id, for example,  is not allocated to the VM until it is actually created.

Notice that `terraform plan` will automatically run `terraform validate`

### Apply the Deployment

The `terraform apply` command will execute and create the deployment. The `apply' command will automatically run the `plan` command to generate a current deployment plan.

```console 
$terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

aws_instance.my_rc2_instance: Creating...
aws_instance.my_rc2_instance: Still creating... [10s elapsed]
aws_instance.my_rc2_instance: Still creating... [20s elapsed]
aws_instance.my_rc2_instance: Still creating... [30s elapsed]
aws_instance.my_rc2_instance: Creation complete after 33s [id=i-00557ff166bd790a9]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

### Confirm the results

At the EC2 console check to see that the instance is running.

![](images/lab1-2_aws.png?raw=true)

`

## Step Two - Modify the resource

In this step, we are going to change the resource and then Terraform will revert it back to what we specified in the Terraform code.

### The State File

Terraform state file is a description of the current deployment and all the properties of each cloud artifact under its management. This is a Json file named `terraform.tfstate` and the first part of it looks like this:

```json
{
  "version": 4,
  "terraform_version": "1.7.4",
  "serial": 5,
  "lineage": "637f7575-df52-1c42-8f8b-8c31214d28f1",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "my_rc2_instance",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0f403e3180720dd7e",
            "arn": "arn:aws:ec2:us-east-1:983803453537:instance/i-00557ff166bd790a9",
            "associate_public_ip_address": true,
            "availability_zone": "us-east-1a",
            "capacity_reservation_specification": [
              {
                "capacity_reservation_preference": "open",
                "capacity_reservation_target": []
              }
            ],
            "cpu_core_count": 1,
            "cpu_threads_per_core": 1,
            "credit_specification": [
              {
                "cpu_credits": "standard"
              }
            ],
            "disable_api_termination": false,
            "ebs_block_device": [],
            "ebs_optimized": false,
            "enclave_options": [
              {
                "enabled": false
              }
            ],
            "ephemeral_block_device": [],
            "get_password_data": false,
            "hibernation": false,
            "host_id": null,
            "iam_instance_profile": "",
            "id": "i-00557ff166bd790a9",
            "instance_initiated_shutdown_behavior": "stop",
            "instance_state": "running",
            "instance_type": "t2.micro",
            "ipv6_address_count": 0,
            "ipv6_addresses": [],
            "key_name": "",
            "launch_template": [],
            "metadata_options": [
              {
                "http_endpoint": "enabled",
                "http_put_response_hop_limit": 2,
                "http_tokens": "required",
                "instance_metadata_tags": "disabled"
              }
            ],
            "monitoring": false,
            "network_interface": [],
            "outpost_arn": "",
            "password_data": "",
            "placement_group": "",
            "placement_partition_number": null,
            "primary_network_interface_id": "eni-03871db226e799ea5",
            "private_dns": "ip-172-31-80-90.ec2.internal",
            "private_ip": "172.31.80.90",
            "public_dns": "ec2-44-204-78-106.compute-1.amazonaws.com",
            "public_ip": "44.204.78.106",
            "root_block_device": [
              {
                "delete_on_termination": true,
                "device_name": "/dev/xvda",
                "encrypted": false,
                "iops": 3000,
                "kms_key_id": "",
                "tags": {},
                "throughput": 125,
                "volume_id": "vol-06dc9e714ac48d4c0",
                "volume_size": 8,
                "volume_type": "gp3"
              }
            ],
            "secondary_private_ips": [],
            "security_groups": [
              "default"
            ],
            "source_dest_check": true,
            "subnet_id": "subnet-04ca3a25",
            "tags": {
              "Name": "Terraform"
            },
            "tags_all": {
              "Name": "Terraform"
            },
            "tenancy": "default",
            "timeouts": null,
            "user_data": null,
            "user_data_base64": null,
            "volume_tags": null,
            "vpc_security_group_ids": [
              "sg-f3dcd6dc"
            ]
          },
          "sensitive_attributes": [],
          "private": "eyJlMmJmYjczMC1lY2FhLTExZTYtOGY4OC0zNDM2M2JjN2M0YzAiOnsiY3JlYXRlIjo2MDAwMDAwMDAwMDAsImRlbGV0ZSI6MTIwMDAwMDAwMDAwMCwidXBkYXRlIjo2MDAwMDAwMDAwMDB9LCJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    }
  ],
  "check_results": null
}

"terraform_version": "1.7.4",
  "serial": 1,
  "lineage": "d8f35c31-7f52-8fe0-4c3d-50372d28099e",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "ibm_resource_group",
      "name": "alpha_rg",
      "provider": "provider[\"registry.terraform.io/ibm-cloud/ibm\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "created_at": "2024-03-10T22:26:06.850Z",
            "crn": "crn:v1:bluemix:public:resource-controller::a/b420fb31a3024a2e8b44e928ed41f042::resource-group:7cb9140647f54860848e4bdc9be53216",
            "default": false,
            "id": "7cb9140647f54860848e4bdc9be53216",
            "name": "alpha",
            "payment_methods_url": null,
            "quota_id": "a3d7b8d01e261c24677937c29ab33f3c",
            "quota_url": "/v2/quota_definitions/a3d7b8d01e261c24677937c29ab33f3c",
            "resource_linkages": [],
            "state": "ACTIVE",
            "tags": null,
            "teams_url": null,
            "updated_at": "2024-03-10T22:26:06.850Z"
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    }
```

**This file should never be edited directly.** If you do, very bad things might happen. This file should only be modified by Terraform.

If you delete this file, then Terraform has no idea what resources it is managing. Another warning, do not delete this file until all resources under Terraform's management have been destroyed, otherwise you might get some resource leakage.

### Modify the instance in the console

In the console, rename the instance from "Terrform" to "HelloWorld" At this point the specified state is now out of sync with the actual state of the resource.

![](images/lab1-3_aws.png?raw=true)


### Run Terraform to restore the configuration

Now run `terraform plan.` The output will show what terraform needs to do to restore the cloud environment to a state consistent with what was specified.

```console
terraform plan
aws_instance.my_rc2_instance: Refreshing state... [id=i-00557ff166bd790a9]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.my_rc2_instance will be updated in-place
  ~ resource "aws_instance" "my_rc2_instance" {
        id                                   = "i-00557ff166bd790a9"
      ~ tags                                 = {
          ~ "Name" = "HelloWorld" -> "Terraform"
        }
      ~ tags_all                             = {
          ~ "Name" = "HelloWorld" -> "Terraform"
        }
        # (27 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

```

Run 'terraform apply' to let Terraform undo the changes that were made manually.

```console
terraform apply
aws_instance.my_rc2_instance: Refreshing state... [id=i-00557ff166bd790a9]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.my_rc2_instance will be updated in-place
  ~ resource "aws_instance" "my_rc2_instance" {
        id                                   = "i-00557ff166bd790a9"
      ~ tags                                 = {
          ~ "Name" = "HelloWorld" -> "Terraform"
        }
      ~ tags_all                             = {
          ~ "Name" = "HelloWorld" -> "Terraform"
        }
        # (27 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.my_rc2_instance: Modifying... [id=i-00557ff166bd790a9]
aws_instance.my_rc2_instance: Modifications complete after 2s [id=i-00557ff166bd790a9]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Confirm at the console the manual change was reverted.


```console
D:\lab1>ibmcloud resource groups
Retrieving all resource groups under account b4xxxxxxxxxxxxxxxxxxxxxxxxxxxx42 as xxxxxx@xxxxxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
alpha     7cb9140647f54860848e4bdc9be53216   false           ACTIVE
```
### Destroying the deployment

The `terraform destroy` command removes all the resources in the state file that it created and is managing.

Run it then confirm in the console that the EC2 instance has been terminated

## Additional tasks

### Overwriting resources

Deploy the EC2 instance, then change the ami in the Terraform code. Run `terraform plan` and explain what Terraform will do and why.

## End Lab