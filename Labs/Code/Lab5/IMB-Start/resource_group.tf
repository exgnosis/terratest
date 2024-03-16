
resource "ibm_resource_group" "my_rg" {
  name = var.res_group
  tags = ["source:Terraform", "lab:Lab 5", "team:Dev Team 1"]
}
