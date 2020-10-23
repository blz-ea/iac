variable "dependencies" {
  type = list(string)
  default = []
}

variable "env" {
  type = list(string)
  default = []
}

variable "labels" {
  type = list(string)
  default = []
}

variable "command" {
  type = list(string)
  default = []
}

variable "ports" {
  type = list(map(string))
  default = []
}

variable "container_name" {
  type = string
  default = "registry_container"
}

variable "image_version" {
  type = string
  default = "latest"
}

variable "networks_advanced" {
  type = list(string)
  default = []
}