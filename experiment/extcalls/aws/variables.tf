
variable "project_prefix" {
  default = "faasterbench"
}

variable "runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16.x"
}

variable "LANGUAGES1" {
  type    = string
  default = "en"
}

variable "LANGUAGES2" {
  type    = number
  default = "de"
}

variable "handler"{
  type    = string
  default = "wrapperTest"
}
variable "WRAPPERCOUNT"{
  type    = number
  default = 5
}