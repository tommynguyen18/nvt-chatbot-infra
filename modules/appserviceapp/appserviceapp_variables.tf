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

variable "service_name" {
  description = "A name to reflect the type of the app service e.g: web, api."
  type        = string
}

variable "app_settings" {
  description = "A list of app settings pairs to be assigned to the app service"
  type        = map(string)
}

variable "app_command_line" {
  description = "The cmd line to configure the app to run."
  type        = string
}

variable "python_version" {
  description = "the application stack python version to set for the app service."
  type        = string
  default     = "3.10"
}

variable "always_on" {
  description = "The always on setting for the app service."
  type        = bool
  default     = true
}

variable "docker_image_name" {
  description = "example: appsvc/staticsite:latest"
  type        = string
}

variable "docker_registry_url" {
  default = "https://index.docker.io"
}


