variable "k8s_config_file_path" {
  type = string
  description = "K8s configuration file path"
}

variable "metallb_ip_range" {
  type = string
  description = "IP range that Metallb will use for Load Balancers"
}

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare API token"
}

variable "cloudflare_account_email" {
  type = string
  description = "Cloudflare account email"
}

variable "domain_name" {
  type = string
  description = "Domain name"
}