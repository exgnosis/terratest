# Lab IBM 2 - Terraform Resource Directives

##### Working with resource directives

---

## Objectives

In this lab, you will create a object bucket and a VM.

Do not delete your code when you are done, you will be adding to it in the next several labs.

## Part One - Creating IBM Object bucket

#### Documentation

To see what sort of attributes we need to create a bucket, refer to the documentation [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

Notice that there are no required arguments and all the values needed to create the bucket can be optionally supplied by AWS.

#### Terraform initialization

First, create the `providers.tf` file

```terraform
terraform {
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

Run 'terraform init' to initialize the backend

```console
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding ibm-cloud/ibm versions matching "~> 1.0"...
- Installing ibm-cloud/ibm v1.63.0...
- Installed ibm-cloud/ibm v1.63.0 (self-signed, key ID AAD3B791C49CC253)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

#### Set up a resource group

Create a file called `resourcegroup.tf`.

Start by creating a storage group for the lab.

```terraform
resource "ibm_resource_group" "MyRG" {
  name = "Lab2"
}
```
Run the Terraform commands to validate and create the resource 

Check to see either at the console or at the command line that the resource has been created.

```console
$ibmcloud resource groups
Retrieving all resource groups under account bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2 as xxxxxa@xxxxxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
Lab2      be7d30699358407a9505ec07c65e8de6   false           ACTIVE
```

As you add more code and run apply, the resources that have already been created by Terraform will be untouched.

### Create the storage service.

Check the required arguments for creating a COS

[Storage Service](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance)

Add the cloud object storage service in a file called `bucket.tf`

Notice that the code puts the COS in the resource group we just created.

```terraform 
resource "ibm_resource_instance" "my_cos" {
  name              = "mycos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = ibm_resource_group.my_rg.id
  tags              = ["terraform", "Lab2"]
}
```
Confirm that the COS has been added.

```console
$ ibmcloud target -g Lab2
Targeted resource group Lab2

$ ibmcloud resource service-instances --service-name cloud-object-storage
Retrieving instances with type service_instance in resource group Lab2 in all locations 
OK
Name    Location   State    Type               Resource Group ID
mycos   global     active   service_instance   be7d30699358407a9505ec07c65e8de6
```

#### Create the bucket

Add the code the `bucket.tf` file  to create the bucket.

**Important** Your bucket name must be unique so replace "zippy-the-wonder-llama-9989" in the code below with your own unique name consisting of lower case letters, numbers and "-". This name must be unique across the known universe since it is mapped to a URL used to access the bucket contents.

```terraform
resource "ibm_cos_bucket" "my_bucket" {
  bucket_name          = "zippy-the-wonder-llama-9989"
  resource_instance_id = ibm_resource_instance.COS.id
  region_location      = "us-south"
  storage_class        = "standard"
}
```

Validate, plan and run the code. You should one resource being created since previous applications of 'terraform apply' created the other two resources.

Check to see the resources are there.

![](images/lab2cos1.png?raw=true)

![](images/lab2cos2.png?raw=true)

#### Clean up

Rename the file `bucket.tf` to `bucket.tf.old`. Run `terraform plan` and see that the bucket and COS will be removed.

Run `terraform apply` to remove the COS and bucket.

---

## Part two: Creating a VM

Unlike the AWS case, creating a VM in IBM Cloud requires some resources to be defined that are defaults in the AWS environment

#### Set up

You can continue adding to the code from part one, as long as you have changed the name of the `bucket.tf` file so you don't keep creating and destroying the bucket from part one.

The documentation for the IBM compute instance is [here](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_instance)

Because there are a lot of dependencies, we will create those first then create the actual VM

#### ssh keys

The VM must have an ssh key associated with it. In a file called `keys.tf` we define a ssh key resource

The documentation for this resource is [here](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_ssh_key
)
Notice that we are adding it to the resource group "lab2"

```terraform 
resource "ibm_is_ssh_key" "my_ssh_key" {
  resource_group = ibm_resource_group.my_rg.id
  name       = "lab2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
  type       = "rsa"
}
```
Run the Terraform commands to validate and create the key resources

#### VPC and subnet

We have to create the VM on a subnet of a VPC. Since there is not a default VPC, we have to create one in a file called `network.tf`

Documentation for the VPC is [here](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc)

And we have to create a subnet for VM placement.

Documentation for the subnet is [here](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_subnet)

``` terraform
resource "ibm_is_vpc" "my_vpc" {
  name = "myvpc"
  resource_group = ibm_resource_group.my_rg.id
}

resource "ibm_is_subnet" "my_subnet" {
  name            = "mysubnet"
  vpc             = ibm_is_vpc.my_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}
```

Run the Terraform code to instantiate the network artifacts.


#### Validate

Check to see that the artifacts are up and running. Go into the console and check the resources - you should see two networking resources, one will be the VPC you created and a default security group that was also created along with the VPC

![](images/labibm2-1.png?raw=true)

Select the VP and select ssh keys to see the key you created

![](images/labibm2-2.png?raw=true)

And check to see that the subnet defined is also there

![](images/labibm2-3.png?raw=true)

#### Add the VM

In a file `compute.tf` add the following code. Notice we don't have to create a security group because a default one was created when we created the VPC

```terraform
resource "ibm_is_instance" "my_vm" {
  name    = "mycompute"
  vpc     = ibm_is_vpc.my_vpc.id
  zone    = "us-south-1"
  image   = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
  resource_group = ibm_resource_group.my_rg.id

  profile = "bx2-2x8"
  
  primary_network_interface {
    subnet = ibm_is_subnet.my_subnet.id
   # security_groups = [ibm_is_security_group.my.id]
  }
  keys = [
    ibm_is_ssh_key.my_ssh_key.id
  ]
}
```


#### Validate

In the console, to the resources page and note that there should be a compute resource.

![](images/labibm2-4.png?raw=true)

Opening up the resource, confirm its configuration

![](images/labibm2-5.png?raw=true)

#### Clean up

Destroy the resources using `terraform destroy` and confirm that they are no longer present (more specifically, that you aren't going to be billed for them)

Do not delete your code since you will be modifying it in the next lab.

---

## End Lab

