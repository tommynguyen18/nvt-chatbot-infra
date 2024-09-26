variable "account_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "container_name" {
  type = string
  default = "smart-bot-documents"
}

variable "sas_start" {
  type = string
}

variable "sas_end" {
  type = string
}