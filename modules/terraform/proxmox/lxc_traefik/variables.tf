variable "user" {
  type = any
}

variable "proxmox" {
  type = any
}

variable "consul" {
  type = any
}

variable "domain" {
    type = any
}

variable "vztmpl" {
  type = any
}

variable "data" {
    type = any
}

variable "dependencies" {
  type = any
  default = []
}

variable "cli_options" {
  type = list
  default = []
}

variable "environment" {
  type = list
  default = []
}

variable "dynamic_config" {
  type = list
  default = []
}
