
variable "auth" {
  type = map
  default = {}
}

variable "mounts" {
  type = list(map(string))
}


variable "hostname" {
  type = string
  default = "terraform-pve-lxc"
}


variable "memory" {
  type = number
  default  = 1024
  description = "Memory allocated to the container"
}


variable "network" {
  type = map
  description = "Network configuration"
  default = {
    name = "eht0"
    bridge = "vmbr0"
    ip = "dhcp"
    ip6 = "dhcp"
  }
}

variable "ostemplate" {
  type = string
  description = "OS template to be applied to the container"
}

variable "password" {
  type = string
}


variable "storage" {  
  type = string
  default = "local-lvm"
  description = "Storage that will be used to store the container"  
}

variable "target_node" {
  default = "pve"
  type = string
}

variable "unprivileged" {
  type = bool
  default = true
}

variable "start" {
  type = bool
  default = true
}

variable "onboot" {
  type = bool
  default = true
}






