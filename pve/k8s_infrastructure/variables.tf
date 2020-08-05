#############################################################
# Kubernetes variables
#############################################################
variable "k8s_config_file_path" {
  type = string
  description = "K8s configuration file path"
}

variable "metallb_ip_range" {
  type = string
  description = "IP range that Metallb will use for Load Balancers"
}

#############################################################
# Domain variables
#############################################################

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare API token"
  default = ""
}

variable "cloudflare_account_email" {
  type = string
  description = "Cloudflare account email"
  default = ""
}

variable "cloudflare_zone_name" {
  type = string
  description = "Cloudflare Domain name"
  default = ""
}

#############################################################
# Storage variables
#############################################################
# NFS Server
variable "nfs_default_storage_class" {
  type = bool
  description = "Enables NFS Server as default Storage Class provisioner"
  default = false
}

variable "nfs_server_address" {
  type = string
  description = "NFS server IP/Name"
  default = ""
}

# Gluster Server
variable "gluster_cluster_endpoints" {
  type = list(string)
  default = []
  description = "List of Gluster cluster endpoints"
}
