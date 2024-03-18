
variable "ami_type" {
    type = string
    default = "ami-080e1f13689e07408"
}

variable "inst_type" {
    type = string
    default = "t2.nano"
}

variable VM_name {
    type = string
    default = "EC2-Module"
}