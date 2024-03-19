
variable "project_prefix" {
  default = "faasterbench"
}

variable "azure_runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs18.x"
}

variable "aws_runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs18.x"
}

variable "handler"{
  type    = string
  default = "wrapperTest"
}
variable "WRAPPERCOUNT"{
  type    = number
  default = 10
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

variable "google_runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16"
}