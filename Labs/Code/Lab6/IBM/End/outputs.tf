output  "Neo" {
    value = ibm_is_instance.my_vm[0].tags
    description = "Outputs a single string"
}
output  "Everyone" {
    value =ibm_is_instance.my_vm[*].tags
    description = "Outputs a list of strings"
}