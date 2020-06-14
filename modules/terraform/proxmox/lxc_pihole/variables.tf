variable "user" {
  type = any
}

variable "proxmox" {
  type = any
}

variable "domain" {
    type = any
}

variable "vztmpl" {
  type = any
}

variable "consul" {
  type = any
}

variable "data" {
  type = any
}

variable "dependencies" {
  type = list
  default = []
}

variable "tags" {
  type = list(string)
  default = []
}
