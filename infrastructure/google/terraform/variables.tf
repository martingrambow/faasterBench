variable "project_id" {
    default = "csbws2223"
}

variable "region" {
    default = "europe-west1"
}
variable "runtime" {
  description = "The runtime in which to run the function. Required when deploying a new function, optional when updating an existing function."
  type        = string
  default     = "nodejs16"
}