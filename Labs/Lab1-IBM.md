# Lab IBM 1 - Terraform workflow

##### Managing an IBM cloud resource group with tTerraform

---

## Objectives

In this lab, you will explore the Terraform workflow by creating, modifying  and destroying an IBM Cloud resource group

## Setup 

For this lab, you will want to use either the IBM Cloud console or the IBM Cloud CLI to check on the status of your deployment and to modify it outside Terraform.

The lab assumes that you have created an environment variable that contains your API key. If you haven't, you can include it in the _providers.tf_ file.

## Step One 

In this step you will confirm the exising configuration for your resource groups. If you have a newly created account, then you will have a single _Default_ resource group.

If you have other resource groups, running your Terraform code will not affect them or any other resource you have running. Terraform _only_ works with the resources it has created - it is effectively blind to other resources unless it specifically queries them.

### Check existing resource groups

Make sure you are logged into your cloud account with `ibmcloud login` and that you in the `us-south` region. You can specify this in your provider directive

At the CLI, check for the resource groups like this:

```console
D:\lab1>ibmcloud resource groups
Retrieving all resource groups under account b4xxxxxxx042 as xxxx@xxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
```
Or at console
 
 ![](images/lab1-1.png?raw=true)

### Create the providers file

Create a file called `providers.tf` which looks like this:

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
 # Not recommended but you can include your API key
 # ibmcloud_api_key = "YOUR_IBM_CLOUD_API_KEY"
}
```
### Initialize Terraform

This provider block can npw be used by `terraform init` to download and install the IBM Cloud plug in.

```console
D:\lab1>terraform init

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

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

 If you examine the directory you ran this in, you will see a new directory that contains the plug-in code. Explore this and find the _README.me_ file and open it up. Notice that it contains the instructions for building this specific plugin from the source code.

### Adding the configuration code

Create a new file called `main.tf`, or whatever else you want as long as it has the `.tf` extension. 

Add the following code to it.

```terraform
resource "ibm_resource_group" "alpha_rg" {
  name = "alpha"
}
```
 The keyword _resource_ tells Terraform that this is a resource description. The _"ibm_resource_group"_ string identifies which IBM cloud resource type this specification refers to.
 
The string "alpha_rg" is the local name by which we can refer to this resource _in the Terraform code,_ it is not communicated in any way to the IBM cloud. 

Inside the braces are the parameters that the cloud needs to instantiate this resource. In the case of a resource group, the only parameter needed is the name of the resource group.

### Validate the code

The validator is a lightweight syntax checker that ensures your Terraform code is syntactically correct _before_ contacting the cloud provider.

Run the validator as shown. If you have written the code correctly, then it should pass.

```console
D:\lab1>terraform validate
Success! The configuration is valid.
```
Now invalidate the code by commenting out the name parameter.

```terraform
resource "ibm_resource_group" "alpha_rg" {
 # name = "alpha"
}
```

Run validate again and the error is picked up because the plugin has a description of what parameters are required for a particular resource

```console
D:\lab1>terraform validate
╷
│ Error: Missing required argument
│
│   on main.tf line 2, in resource "ibm_resource_group" "alpha_rg":
│    2: resource "ibm_resource_group" "alpha_rg" {
│
│ The argument "name" is required, but no definition was found.

```
Uncomment out the line you commented out and run validate again to confirm your code is valid

### Plan the deployment

Running `terraform plan` will do several things.  

First it will query the provider to see what already may have been deployed by terraform earlier. It then compares this information to the configuration described in your `*.tf` files.

It then creates a DAG to figure out what needs to be created, what needs to modified and what needs to be deleted in the cloud to make the existing deployment conform to the one you specified.

```console
D:\lab1>terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # ibm_resource_group.alpha_rg will be created
  + resource "ibm_resource_group" "alpha_rg" {
      + created_at          = (known after apply)
      + crn                 = (known after apply)
      + default             = (known after apply)
      + id                  = (known after apply)
      + name                = "alpha"
      + payment_methods_url = (known after apply)
      + quota_id            = (known after apply)
      + quota_url           = (known after apply)
      + resource_linkages   = (known after apply)
      + state               = (known after apply)
      + teams_url           = (known after apply)
      + updated_at          = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

```
 The `terraform plan` command doesn't make any changes, it just tells you what it will do.

Notice that only the `name` parameter has a value. All the others are optional or set when the resource is created. The resource group id is not allocated to the rg until it is actually created.

Notice that `terraform plan` will automatically run `terraform validate`

### Apply the Deployment

The `terraform apply` command will execute and create the deployment. The `apply' command will automatically run the `plan` command to generate a current deployment plan.

```console 
D:\lab1>terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # ibm_resource_group.alpha_rg will be created
  + resource "ibm_resource_group" "alpha_rg" {
      + created_at          = (known after apply)
      + crn                 = (known after apply)
      + default             = (known after apply)
      + id                  = (known after apply)
      + name                = "alpha"
      + payment_methods_url = (known after apply)
      + quota_id            = (known after apply)
      + quota_url           = (known after apply)
      + resource_linkages   = (known after apply)
      + state               = (known after apply)
      + teams_url           = (known after apply)
      + updated_at          = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

ibm_resource_group.alpha_rg: Creating...
ibm_resource_group.alpha_rg: Creation complete after 2s [id=7cb9140647f54860848e4bdc9be53216]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Confirm the results

At the command line, you can list all the rgs.

```console
D:\lab1>ibmcloud resource groups
Retrieving all resource groups under account b420fbxxxxxxxxxxxxxxxxxxxxxxf042 as xxxxxx@xxxxxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
alpha     7cb9140647f54860848e4bdc9be53216   false           ACTIVE
```

Or at the console

![](images/lab1-2.png?raw=true)

## Step Two

In this step, we are going to change the resource and then Terraform will revert it back to what we specified in the Terraform code.

### The State File

Terraform state file is a description of the current deployment and all the properties of each cloud artifact under its management. This is a Json file named `terraform.tfstate` and the first part of it looks like this:

```json
{
  "version": 4,
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

### Modify the resource group

In the console, rename the resource group from "alpha" to "beta." At this point the state file is now out of sync with the actual resource.

![](images/lab1-3.png?raw=true)


Confirm the change in name at the command line

```console
D:\lab1>ibmcloud resource groups
Retrieving all resource groups under account b42xxxxxxxxxxxxxxxxxxxxxxxxxxx42 as xxxxxx@xxxxxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
beta      7cb9140647f54860848e4bdc9be53216   false           ACTIVE
```

### Run Terraform to restore the configuration

Now run `terraform plan.` The output will show what terraform needs to do to restore the cloud environment to a state consistent with what was specified.

```console
D:\lab1>terraform plan
ibm_resource_group.alpha_rg: Refreshing state... [id=7cb9140647f54860848e4bdc9be53216]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # ibm_resource_group.alpha_rg will be updated in-place
  ~ resource "ibm_resource_group" "alpha_rg" {
        id                = "7cb9140647f54860848e4bdc9be53216"
      ~ name              = "beta" -> "alpha"
        # (8 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Run 'terraform apply' to let Terraform undo the changes that were made manually.

```console
D:\lab1>terraform apply
ibm_resource_group.alpha_rg: Refreshing state... [id=7cb9140647f54860848e4bdc9be53216]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # ibm_resource_group.alpha_rg will be updated in-place
  ~ resource "ibm_resource_group" "alpha_rg" {
        id                = "7cb9140647f54860848e4bdc9be53216"
      ~ name              = "beta" -> "alpha"
        # (8 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

ibm_resource_group.alpha_rg: Modifying... [id=7cb9140647f54860848e4bdc9be53216]
ibm_resource_group.alpha_rg: Modifications complete after 1s [id=7cb9140647f54860848e4bdc9be53216]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Confirm at the console or command line that the change was effected


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

```console
D:\lab1>terraform destroy
ibm_resource_group.alpha_rg: Refreshing state... [id=7cb9140647f54860848e4bdc9be53216]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  - destroy

Terraform will perform the following actions:

  # ibm_resource_group.alpha_rg will be destroyed
  - resource "ibm_resource_group" "alpha_rg" {
      - created_at        = "2024-03-10T22:26:06.850Z" -> null
      - crn               = "crn:v1:bluemix:public:resource-controller::a/b420fb31a3024a2e8b44e928ed41f042::resource-group:7cb9140647f54860848e4bdc9be53216" -> null
      - default           = false -> null
      - id                = "7cb9140647f54860848e4bdc9be53216" -> null
      - name              = "alpha" -> null
      - quota_id          = "a3d7b8d01e261c24677937c29ab33f3c" -> null
      - quota_url         = "/v2/quota_definitions/a3d7b8d01e261c24677937c29ab33f3c" -> null
      - resource_linkages = [] -> null
      - state             = "ACTIVE" -> null
      - updated_at        = "2024-03-10T22:45:35.560Z" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

ibm_resource_group.alpha_rg: Destroying... [id=7cb9140647f54860848e4bdc9be53216]
ibm_resource_group.alpha_rg: Destruction complete after 2s

Destroy complete! Resources: 1 destroyed.
```

Confirm at the console or command line

```console
D:\lab1>ibmcloud resource groups
Retrieving all resource groups under account bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx42 as xxxxxx@xxxxxxxx.ca...
OK
Name      ID                                 Default Group   State
Default   7159fa13b75e4f92a897bc3bb653c560   true            ACTIVE
```
## Additional tasks

### Overwriting resources

Manually create a resource group called "alpha" then run your Terraform code again. Explain the results.

## End Lab