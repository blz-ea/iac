#############################################################
# Proxmox API variables
#############################################################
variable "proxmox_api_url" {
  description = "Proxmox api url"
  type        = string
  default     = "https://192.168.1.1:8006"
}

variable "proxmox_api_username" {
  description = "Proxmox api username"
  type        = string
  default     = "root@pam"
}

variable "proxmox_api_password" {
  description = "Proxmox api password"
  type        = string
  default     = "password"
}

variable "proxmox_api_otp" {
  description = "Proxmox api OTP"
  type        = string
  default     = ""
}

variable "proxmox_api_tls_insecure" {
  description = "Allow insecure connection to Proxmox API"
  type        = bool
  default     = true
}

#############################################################
# Proxmox Cluster Settings
#############################################################
variable "default_pool_id" {
  description = "Default Pool that will be created in the cluster"
  type        = string
  default     = "pve"
}

#############################################################
# Proxmox Node variables
#############################################################
variable "default_time_zone" {
  description = "Time zone that will be used on Proxmox nodes"
  type        = string
  default     = "UTC"
}

variable "default_data_store_id" {
  description = "Data store for VZDump backup file, ISO image, Container template, Snippets"
  type        = string
  default     = "local"
}

variable "default_vm_store_id" {
  description = "Data store for that supports Disk image and Containers (e.g. storage with type LVM-Thin)"
  type        = string
  default     = "local-lvm"
}

#############################################################
# Proxmox Domain Settings
#############################################################
variable "domain_name" {
  description = "Domain name"
  type = string
}

variable "dns_servers" {
  description = "List of external DNS Servers"
  type = list(string)
  default = [
    "1.1.1.1",
    "8.8.8.8",
  ]
}

#############################################################
# Cloudflare API variables
#############################################################
variable "cloudflare_account_email" {
  description = "Cloudflare account email"
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  default     = ""
}

#############################################################
# Default user settings
#############################################################
variable "user_name" {
  description = "Default username"
  type        = string
  default     = "deploy"
}

variable "user_password" {
  description = "Default password"
  type        = string
}

variable "user_ssh_public_key_location" {
  description = "SSH public key location path"
  type        = string
  default      = "~/.ssh/id_rsa.pub"
}

variable "user_email" {
  description = "Default administrators's email"
  type = string
}

#############################################################
# Packer variables
#############################################################
variable "packer_default_cores" {
  description = "Amount of CPU cores that will be allocated to a VM"
  type = number
  default = 2
}

#############################################################
# Kubernetes Cluster variables
#############################################################
variable "k8s_vm_provisioner_user_public_keys" {
  description = "SSH public keys that will be added to each node in the cluster"
  default = []
  type = list(string)
}

variable "k8s_vm_dns" {
  description = "DNS server that will be used by the virtual machines (e.g 192.168.1.1)"
  type = string
}

#############################################################
# Kubernetes Cluster  - HAProxy load balancer variables
#############################################################
variable "k8s_vm_haproxy_count" {
  description = "Number of VMs for Haproxy"
  type        = number
  default     = 0
}

variable "k8s_vm_haproxy_vip" {
  description = "IP address that will be used by keepalived (e.g 192.168.1.2)"
  type = string
}

variable "k8s_vm_haproxy_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_haproxy_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_haproxy_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_haproxy_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_haproxy_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_haproxy_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Cluster  - Master Node variables
#############################################################
variable "k8s_vm_master_count" {
  description = "Number of Master Nodes"
  type        = number
  default     = 3
}

variable "k8s_vm_master_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_master_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_master_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_master_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_master_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_master_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Cluster  - Worker Node variables
#############################################################
variable "k8s_vm_worker_count" {
  description = "Number of Worker Nodes"
  type        = number
  default     = 3
}

variable "k8s_vm_worker_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_worker_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_worker_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_worker_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_worker_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_worker_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Infrastructure variables
#############################################################
variable "k8s_metallb_ip_range" {
  # Reference: https://metallb.universe.tf/configuration/
  description = "IP range that will be used by Metallb"
  type = string
}

# Storage
# NFS Server
variable "k8s_nfs_default_storage_class" {
  type = bool
  description = "Enables NFS Server as default Storage Class provisioner"
  default = false
}

variable "k8s_nfs_server_address" {
  type = string
  description = "NFS server IP/Name"
  default = ""
}

# Gluster Server
variable "k8s_gluster_cluster_endpoints" {
  type = list(string)
  default = []
  description = "List of Gluster cluster endpoints"
}


#############################################################
# Bastion Host variables
#############################################################
variable "digital_ocean_api_key" {
  description = "Digital Ocean API key"
  default = ""
  type = string
}

variable "bastion_user_name" {
  description = "Bastion host default username"
  type        = string
  default     = "deploy"
}

variable "bastion_ssh_port" {
  description = "Set desired SSH access port. Provisioner will change default port (22) to specified below"
  type        = number
  default     = 45321
}

variable "bastion_ssh_public_key_location" {
  description = "SSH public key location path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_hostname" {
  description = "Droplet's Hostname"
  type        = string
  default     = "bastion"
}

variable "bastion_region" {
  description = "Digital Ocean region"
  type        = string
  default     = "nyc3"
}

variable "bastion_size" {
  description = "Digital Ocean droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "bastion_image" {
  description = "Digital Ocean OS image name"
  type        = string
  default     = "ubuntu-19-10-x64"
}

#############################################################
# Bastion Host - Container variables
#############################################################
variable "bastion_traefik_container_file_cfg" {
  description = "Traefik container's file configuration"
  # Reference: https://docs.traefik.io/reference/dynamic-configuration/file/
  type = map(any)
  default = {}
}

variable "bastion_traefik_container_network_advanced" {
  description = "List of networks Traefik will be a part of"
  type = list(string)
  default = []
}

variable "bastion_traefik_container_basic_auth" {
  description = "List of basic authentication credentials for Traefik"
  # Can be generated using: htpasswd -nb <name> <password>
  type = list(string)
  default = []
}

variable "bastion_drone_server_rpc_secret" {
  description = "Drone Server RPC Secret (Any random string)"
  type = string
  default = ""
}

variable "bastion_drone_server_github_client_id" {
  description = "Github Client ID; Used by Drone Server for OAuth"
  type = string
  default = ""
}

variable "bastion_drone_server_github_client_secret" {
  description = "Github Client Secret; Used by Drone Server for OAuth"
  type = string
  default = ""
}

variable "bastion_drone_server_user_filter" {
  description = "Allowed users"
  type = string
  default = ""
}

variable "bastion_drone_server_user_admin" {
  description = "Create user Administrator"
  type = string
  default = ""
}

#############################################################
# Authentication variables
#############################################################
variable "github_oauth_client_id" {
  type = string
  description = "Github Oauth Client ID"
  default = ""
}

variable "github_oauth_client_secret" {
  type = string
  description = "Github Oauth Client Secret"
  default = ""
}

variable "k8s_dashboard_token" {
  # Can be found in K8s secrets (`kubernetes-dashboard-token-<unique_id>`) in `kube-system` namespace
  # Provide decoded token
  type = string
  description = "K8s dashboard token"
  default = ""
}