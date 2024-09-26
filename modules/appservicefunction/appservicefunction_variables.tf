variable "service_name" {
  description = "A name to reflect the type of the app service e.g: web, api."
  type        = string
}

variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "appservice_plan_id" {
  description = "The id of the appservice plan to use."
  type        = string
}

variable "app_settings" {
  description = "A list of app settings pairs to be assigned to the app service"
  type        = map(string)
}

variable "storage_account_name" {
  description = "storage_account_name"
  type        = string
}

variable "storage_account_access_key" {
  description = "storage_account_access_key"
  type        = string
}

variable "always_on" {
  description = "The always on setting for the app service."
  type        = bool
  default     = true
}

variable "image_name" {
  description = "image_name"
  type        = string
}

variable "image_tag" {
  description = "image_tag"
  type        = string
  default = "latest"
}

variable "registry_url" {
  description = "registry_url"
  type        = string
  default = "https://index.docker.io"
}