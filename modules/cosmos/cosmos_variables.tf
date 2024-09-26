# ------------- AZURE COSMOSDB -------------
variable "name" {
  type = string
}

variable "location" {
  default = "eastasia"
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}