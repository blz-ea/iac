variable "dependencies" {
  type = any
}

variable "env" {
  type = any
  default = []
}

variable "ports" {
  type = any
  default = []
}

variable "container_name" {
  type = string
  default = "drone_runner_container"
}

variable "networks_advanced" {
  type = any
  default = []
}
