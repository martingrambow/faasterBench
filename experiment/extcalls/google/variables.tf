
variable "project_prefix" {
  default = "faasterbench"
}

variable "RUNTIME" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16"
}

variable "handler"{
  type    = string
  default = "wrapperTest"
}
variable "WRAPPERCOUNT"{
  type    = number
  default = 5
}