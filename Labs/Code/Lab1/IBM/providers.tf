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