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
variable "nfs_server_address" {
  type = string
  description = "NFS server IP/Name"
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

#############################################################
# Services
#############################################################
variable "bitwarden_enabled" {
  type = bool
  description = "Enable Bitwarden"
  default = true
}

variable "pihole_enabled" {
  type = bool
  description = "Enable PiHole"
  default = true
}

variable "radarr_enabled" {
  type = bool
  description = "Enable Radarr"
  default = true
}

variable "sonarr_enabled" {
  type = bool
  description = "Enable Sonarr"
  default = true
}

variable "deemix_enabled" {
  type = bool
  description = "Enable Deemix"
  default = true
}

variable "deemix_arl" {
  type = string
  description = "Deemix ARL. Authentication string obtained from cookies"
  default = ""
}

variable "qbittorrent_enabled" {
  type = bool
  description = "Enable qBittorrent"
  default = true
}

variable "nordvpn_username" {
  type = string
  description = "NordVPN username"
  default = ""
}

variable "nordvpn_password" {
  type = string
  description = "NordVPN password"
  default = ""
}

variable "nordvpn_server" {
  type = string
  description = "NordVPN Server to connect (e.g. us5839)"
  default = ""
}

variable "mongodb_enabled" {
  type = bool
  description = "Enable MongoDB"
  default = true
}

variable "mongodb_root_password" {
  type = string
  description = "Set MongoDB root password during first run"
  default = ""
}

variable "redis_enabled" {
  type = bool
  description = "Enable Redis"
  default = true
}

variable "redis_password" {
  type = string
  description = "Set Redis password during first run"
  default = ""
}

variable "postgresql_enabled" {
  type = bool
  description = "Enable PostgreSQL"
  default = true
}

variable "postgresql_password" {
  type = string
  description = "Set PostgreSQL password during first run"
  default = "postgresql"
}

variable "pgadmin_enabled" {
  type = bool
  description = "Enable pgAdmin. WebUI for PostgreSQL"
  default = true
}

variable "pgadmin_default_email" {
  type = string
  description = "pgAdmin default email"
  default = "example@domain.com"
}

variable "pgadmin_default_password" {
  type = string
  description = "pgAdmin default password"
  default = "pgadmin"
}

variable "elasticsearch_enabled" {
  type = bool
  description = "Enable Elasticsearch"
  default = true
}

variable "ceph_admin_secret" {
  type = string
  description = "Ceph admin secret. To get the key: > ceph auth get-key client.admin"
  default = ""
}

variable "ceph_user_secret" {
  type = string
  # To create a user account: > ceph --cluster ceph auth get-or-create client.kube mon 'allow r' osd 'allow rwx pool=<pool_name>>'
  description = "Ceph user secret. To get user account key: > ceph --cluster ceph auth get-key client.kube"
  default = ""
}

variable "ceph_monitors" {
  type = string
  description = "Comma separated list of Ceph Monitors (e.g. 192.168.88.1:6789)"
  default = ""
}

variable "ceph_pool_name" {
  type = string
  description = "Ceph pool name that will be used by StorageClass"
  default = ""
}

variable "ceph_admin_id" {
  type = string
  description = "Ceph Admin ID"
  default = "admin"
}

variable "ceph_user_id" {
  type = string
  description = "Ceph User ID"
  default = "kube"
}

variable "nextcloud_enable" {
  type = bool
  description = "Enable Nextcloud"
  default = true
}

variable "nextcloud_db_name" {
  type = string
  description = "Database name that will be used by Nextcloud"
  default = "nextcloud"
}

variable "nextcloud_db_username" {
  type = string
  description = "Username that will be used to access Nextcloud database"
  default = "nextcloud"
}

variable "nextcloud_db_password" {
  type = string
  description = "Password that will be used to access Nextcloud database"
  default = "YiaK7$RNJY4E8$J"
}

variable "nextcloud_admin_username" {
  type = string
  description = "Nextcloud user that will be created during initializtion"
  default = "deploy"
}

variable "nextcloud_admin_password" {
  type = string
  description = "Nextcloud user that will be created during initializtion"
  default = "utwighoghghisodhighhu"
}