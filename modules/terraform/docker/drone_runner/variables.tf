variable "dependencies" {
  type = list(string)
  default = []
}

variable "env" {
  type = list(string)
  default = []
}

variable "ports" {
  type = list(string)
  default = []
}

variable "container_name" {
  type = string
  default = "drone_runner_container"
}

variable "networks_advanced" {
  type = list(string)
  default = []
}
