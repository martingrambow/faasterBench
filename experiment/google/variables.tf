
variable "project_prefix" {
  default = "faasterbench"
}

variable "runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16"
}

variable "TRIALS1" {
  type    = number
  default = 1000000
}

variable "TRIALS2" {
  type    = number
  default = 1100000
}