variable "ami_type" {
  description = "The ami type to be used for the VM"
  type        = string
  default     = "ami-0f403e3180720dd7e"
}

variable "inst_type" {
  description = "Instance type for the VM"
  type        = string
}

variable "owners" {
  description = "Instance type for the VM"
  type        = list(string)
}

