variable "dependencies" {
  type = list(string)
  default = []
}

variable "action" {
  description = "Which action have to be done on the cluster (create, add_worker, remove_worker, or upgrade)"
  default     = "create"
  type        = string
}

#############################################################
# Kubernetes variables
#############################################################
variable "k8s_kubespray_url" {
  description = "Kubespray git repository"
  type        = string
  default     = "https://github.com/kubernetes-incubator/kubespray.git"
}

variable "k8s_kubespray_version" {
  description = "Kubespray repository branch"
  default     = "master"
  type        = string
}

variable "k8s_version" {
  description = "Version of Kubernetes that will be deployed"
  default     = "v1.18.5"
  type        = string
}

variable "k8s_network_plugin" {
  description = "Kubernetes network plugin (calico/canal/flannel/weave/cilium/contiv/kube-router)"
  default     = "calico"
}

#############################################################
# Virtual machines variables
#############################################################
variable "vm_provisioner_type" {
  description = "Type of connection that will be used for provisioning"
  type        = string
  default     = "ssh"
}

variable "vm_provisioner_user" {
  description = "Provisioning username"
  type        = string
  default     = "deploy"
}

variable "vm_provisioner_user_password" {
  description = "Provisioning user's password"
  type        = string
  default     = null
}

variable "vm_provisioner_user_public_keys" {
  description = "List of provisioning user's SSH public keys"
  type        = list(string)
}

variable "vm_vga_type" {
  description = "VGA type for VMs"
  type        = string
  default     = "std"
}

variable "vm_os_type" {
  description = "Operating system type for VMs"
  type        = string
  default     = "l26"
}

variable "vm_name_prefix" {
  description = "Prefix for the name of the virtual machines and the hostname of the Kubernetes nodes"
  default     = "k8s"
}

variable "vm_dns" {
  type = string
  description = "DNS for the Kubernetes nodes"
}

variable "vm_domain" {
  type        = string
  description = "Domain for the Kubernetes nodes"
  default     = ""
}

#############################################################
# HAProxy load balancer variables
#############################################################
variable "vm_haproxy_vip" {
  description = "# IP address that will be used by keepalived"
  type        = string
}

variable "vm_haproxy_count" {
  description = "Number of VMs for Haproxy"
  type        = number
  default     = 0
}

variable "vm_haproxy_proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_haproxy_proxmox_pool_id" {
  description = "Proxmox pool id"
  type        = string
}

variable "vm_haproxy_clone_id" {
  description = "VM template id to clone from"
  type        = number
}

variable "vm_haproxy_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_haproxy_cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "vm_haproxy_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type        = number
  default     = 2048
}

variable "vm_haproxy_ram_floating" {
  description = "Amount of floating RAM"
  type        = number
  default     = 1536
}

variable "vm_haproxy_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type        = string
  default     = "local-lvm"
}

#############################################################
# Master node parameters
#############################################################
variable "vm_master_count" {
  description = "Number of Master Nodes"
  type        = number
  default     = 3
}

variable "vm_master_proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_master_proxmox_pool_id" {
  description = "Proxmox pool id"
  type        = string
}

variable "vm_master_clone_id" {
  description = "VM template id to clone from"
  type        = number
}

variable "vm_master_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_master_cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "vm_master_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type        = number
  default     = 3000
}

variable "vm_master_ram_floating" {
  description = "Amount of floating RAM"
  type        = number
  default     = 2048
}

variable "vm_master_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type        = string
  default     = "local-lvm"
}

#############################################################
# Workers node parameters
#############################################################
variable "vm_worker_count" {
  description = "Number of Worker Nodes"
  type        = number
  default     = 3
}

variable "vm_worker_proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_worker_proxmox_pool_id" {
  description = "Proxmox pool id"
  type        = string
}

variable "vm_worker_clone_id" {
  description = "VM template id to clone from"
  type        = number
}

variable "vm_worker_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_worker_cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "vm_worker_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type        = number
  default     = 2048
}

variable "vm_worker_ram_floating" {
  description = "Amount of floating RAM"
  type        = number
  default     = 1536
}

variable "vm_worker_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type        = string
  default     = "local-lvm"
}