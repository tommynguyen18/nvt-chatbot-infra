# ------------- AZURE WEBAPP -------------
variable "name" {
  type = string
}

variable "location" {
    type = string
}

variable "sku" {
    type = string
    default = "B3"
}

variable "os_type" {
    type = string
    default = "Linux"
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}