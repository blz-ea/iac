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

variable "file_cfg_dynamic" {
  type = map(any)
  default = {}
}

variable "file_cfg_static" {
  type = any
  default = {}
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