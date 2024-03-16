
resource "ibm_resource_group" "my_rg" {
  name = var.res_group
 tags              = [local.source, local.lab, local.team]
}
