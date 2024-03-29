
variable "project_prefix" {
  default = "faasterbench"
}

variable "runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs18.x"
}

variable "TRIALS1" {
  type    = number
  default = 1000000
}

variable "TRIALS2" {
  type    = number
  default = 1100000
}

variable "handler"{
  type    = string
  default = "wrapperTest"
}
variable "WRAPPERCOUNT"{
  type    = number
  default = 5
}

variable "project" {
  type = string
  description = "Project name"
  default ="faasterbench"
}

variable "location" {
  type = string
  description = "Azure region to deploy module to"
  default="germanywestcentral"
}
variable "experiment" {
  type = string
  default = "cpu"
}