#############################################################
# Proxmox API variables
#############################################################

# Proxmox api url
proxmox_api_url = "https://192.168.1.1:8006"

# Proxmox api username
proxmox_api_username = "root@pam"

# Proxmox api password
proxmox_api_password = "password"

# Proxmox api OTP
proxmox_api_otp = ""

# Allow insecure connection to Proxmox API
proxmox_api_tls_insecure = true

#############################################################
# Proxmox Cluster Settings
#############################################################
# Default Pool that will be created in the cluster
default_pool_id = "pve"

#############################################################
# Proxmox Node variables
#############################################################
# Time zone that will be used on Proxmox nodes
default_time_zone = "UTC"

# Data store for VZDump backup file, ISO image, Container template, Snippets
default_data_store_id = "local"

# Data store for that supports Disk image and Containers (e.g. storage with type LVM-Thin)
default_vm_store_id = "local-lvm"

#############################################################
# Proxmox Domain Settings
#############################################################
domain_name = "example.com"

dns_servers = [
  "1.1.1.1",
  "8.8.8.8"
]

#############################################################
# Cloudflare API variables
#############################################################
# Cloudflare API key
cloudflare_api_token = ""

# Cloudflare account email
cloudflare_account_email = "user@example.com"

#############################################################
# Default user variables
#############################################################
# Default username
user_name = "deploy"

# Default password
# user_password = ""

# SSH public key location path
user_ssh_public_key_location = "~/.ssh/id_rsa.pub"

# Default administrators's email
user_email = "deploy@example.com"

#############################################################
# Packer variables
#############################################################
# Amount of CPU cores that will be allocated to a VM
packer_default_cores = 6

#############################################################
# Kubernetes Cluster variables
#############################################################
# SSH public keys that will be added to each node in the cluster
k8s_vm_provisioner_user_public_keys = []

# DNS server that will be used by the virtual machines (e.g 192.168.1.1)
k8s_vm_dns = ""

#############################################################
# Kubernetes Cluster - HAProxy load balancer variables
#############################################################
# Number of VMs for Haproxy
k8s_vm_haproxy_count = 0

# IP address that will be used by keepalived (e.g 192.168.1.2)
k8s_vm_haproxy_vip = ""

# VM id to clone from
k8s_vm_haproxy_clone_id = 0

# Number of CPU cores
k8s_vm_haproxy_cpu_cores = 2

# Number of CPU sockets
k8s_vm_haproxy_cpu_sockets = 1

# Amount of dedicated RAM
k8s_vm_haproxy_ram_dedicated = 2048

# Amount of floating RAM
k8s_vm_haproxy_ram_floating = 1536

# Where on Proxmox VM should be stored (datastore id)
k8s_vm_haproxy_proxmox_datastore_id = "local-lvm"

#############################################################
# Kubernetes Cluster - Master Node variables
#############################################################
# Number of Master Nodes
k8s_vm_master_count = 3

# VM id to clone from
k8s_vm_master_clone_id = 0

# Number of CPU cores
k8s_vm_master_cpu_cores = 2

# Number of CPU sockets
k8s_vm_master_cpu_sockets = 1

# Amount of dedicated RAM
k8s_vm_master_ram_dedicated = 2048

# Amount of floating RAM
k8s_vm_master_ram_floating = 1536

# Where on Proxmox VM should be stored (datastore id)
k8s_vm_master_proxmox_datastore_id = "local-lvm"

#############################################################
# Kubernetes Cluster - Worker Node variables
#############################################################
# Number of Worker Nodes
k8s_vm_worker_count = 3

# VM id to clone from
k8s_vm_worker_clone_id = 0

# Number of CPU cores
k8s_vm_worker_cpu_cores = 2

# Number of CPU sockets
k8s_vm_worker_cpu_sockets = 1

# Amount of dedicated RAM
k8s_vm_worker_ram_dedicated = 2048

# Amount of floating RAM
k8s_vm_worker_ram_floating = 1536

# Where on Proxmox VM should be stored (datastore id)
k8s_vm_worker_proxmox_datastore_id = "local-lvm"

#############################################################
# Kubernetes Infrastructure variables
#############################################################
# IP range that will be used by Metallb
# Reference: https://metallb.universe.tf/configuration/
k8s_metallb_ip_range = "192.168.1.100-192.168.1.200"

# Storage
# NFS server IP/Name
k8s_nfs_server_address = "192.168.1.1"

#############################################################
# Bastion Host variables
#############################################################
# Digital Ocean API Key
digital_ocean_api_key = ""

# Set desired SSH access port.
# Provisioner will change default port (22) to specified below
bastion_ssh_port = 45321

# SSH public key location path
bastion_ssh_public_key_location = "~/.ssh/id_rsa.pub"

# Host name
bastion_hostname = "bastion"

# Digital Ocean region
bastion_region = "nyc3"

# Digital Ocean droplet size
bastion_size = "s-1vcpu-1gb"

# Digital Ocean OS image name
bastion_image = "ubuntu-19-10-x64"

# Traefik static configuration
# Reference: https://docs.traefik.io/reference/dynamic-configuration/file/
bastion_traefik_container_file_cfg = {
  http = {
    middlewares = {}
    routers = {}
    services = {}
  }
}

# List of networks Traefik will be a part of
bastion_traefik_container_network_advanced = [
  "bridge"
]

# List of basic authentication credentials for Traefik
bastion_traefik_container_basic_auth = []

# Drone Server RPC Secret (Any random string)
bastion_drone_server_rpc_secret = ""

# Github Client ID; Used by Drone Server for OAuth
bastion_drone_server_github_client_id = ""

# Github Client Secret; Used by Drone Server for OAuth
bastion_drone_server_github_client_secret = ""

# Allowed users
bastion_drone_server_user_filter = ""

# Create user Administrator
bastion_drone_server_user_admin = ""

#############################################################
# Authentication variables
#############################################################
# Github Oauth Client ID"
github_oauth_client_id = ""

# Github Oauth Client Secret
github_oauth_client_secret = ""

# K8s dashboard token
k8s_dashboard_token = ""

#############################################################
# Variables related to various services
#############################################################
# Deemix ARL. Authentication string obtained from cookies
deemix_arl = ""

# NordVPN username
nordvpn_username = ""

# NordVPN password
nordvpn_password = ""

# NordVPN Server to connect (e.g. us5839)
nordvpn_server = ""

# Set MongoDB root password during first run
mongodb_root_password = ""

# Set Redis password during first run
redis_password = ""

# Set PostgreSQL password during first run
postgresql_password = "postgresql"

# pgAdmin default email
pgadmin_default_email = "example@domain.com"

# pgAdmin default password
pgadmin_default_password = "pgadmin"

# Ceph admin secret. To get the key: > ceph auth get-key client.admin
ceph_admin_secret = ""

# Ceph user secret. To get user account key: > ceph --cluster ceph auth get-key client.kube
ceph_user_secret = ""

# Comma separated list of Ceph Monitors (e.g. 192.168.88.1:6789)"
ceph_monitors = ""

# Existing Ceph pool name that will be used by StorageClass
ceph_pool_name = ""

# Ceph Admin ID
ceph_admin_id = "admin"

# Ceph User ID
ceph_user_id = "kube"
