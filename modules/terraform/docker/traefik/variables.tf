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

variable "file_cfg" {
  type = map(any)
  default = {}
}

variable "command" {
  type = list(string)
  default = []
}

variable "ports" {
  type = list(string)
  default = []
}

variable "container_name" {
  type = string
  default = "traefik_container"
}

variable "image_version" {
  type = string
  default = "latest"
}

variable "networks_advanced" {
  type = list(string)
  default = []
}