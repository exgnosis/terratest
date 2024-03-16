resource "ibm_resource_instance" "my_cos" {
  name              = "mycos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = ibm_resource_group.my_rg.id
  tags              = ["terraform", "Lab3"]
}

resource "ibm_cos_bucket" "my_bucket" {
  bucket_name          = var.bucket_name
  resource_instance_id = ibm_resource_instance.my_cos.id
  region_location      = "us-south"
  storage_class        = "standard"
}