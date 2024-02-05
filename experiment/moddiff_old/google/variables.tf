
variable "project_prefix" {
  default = "faasterbench"
}

variable "RUNTIME" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16"
}

variable "user" {
  type    = string
  default = "timheldt@gmail.com"
}

variable "password" {
  type    = string
  default = ""
}

variable "WRAPPERCOUNT"{
  type    = number
  default = 10
}