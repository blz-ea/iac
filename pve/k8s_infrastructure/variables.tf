#############################################################
# Kubernetes variables
#############################################################
variable "default_time_zone" {
  description = "Time zone that will be used on Proxmox nodes"
  type        = string
  default     = "UTC"
}

variable "k8s_config_file_path" {
  type = string
  description = "K8s configuration file path"
}

variable "metallb_ip_range" {
  type = string
  description = "IP range that Metallb will use for Load Balancers"
}

#############################################################
# Default user settings
#############################################################
variable "user_email" {
  description = "Default administrators's email"
  type = string
}

#############################################################
# Domain variables
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