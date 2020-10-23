#############################################################
# Kubernetes variables
#############################################################
# Time zone that will be used on Proxmox nodes
default_time_zone = "UTC"

# IP range that Metallb will use for Load Balancers
metallb_ip_range = "192.168.1.100-192.168.1.200"

#############################################################
# Default user settings
#############################################################
user_email = "deploy@example.com"

#############################################################
# Domain variables
#############################################################
domain_name = "example.com"

dns_servers = [
  "1.1.1.1",
  "8.8.8.8"
]

# Cloudflare API token
cloudflare_api_token = ""

# Cloudflare account email
cloudflare_account_email = "example@domain.com"

# Zone name
cloudflare_zone_name = "example.com"

#############################################################
# Storage variables
#############################################################
# NFS server IP/Name
nfs_server_address = "192.168.1.1"

#############################################################
# Authentication variables
#############################################################
# Github Oauth Client ID"
github_oauth_client_id = ""

# Github Oauth Client Secret
github_oauth_client_secret = ""

#############################################################
# Services
#############################################################
# Enable Bitwarden
bitwarden_enabled = true

# Enable PiHole
pihole_enabled = true

# Enable Deemix
deemix_enabled = true

# Deemix ARL. Authentication string obtained from cookies
deemix_arl = ""

# Enable qBittorrent
qbittorrent_enabled = true

# NordVPN username
nordvpn_username = ""

# NordVPN password
nordvpn_password = ""

# NordVPN Server to connect (e.g. us5839)
nordvpn_server = ""

# Enable MongoDB
mongodb_enabled = true

# Set MongoDB root password. Executes only during first run
mongodb_root_password = ""

# Set MongoDB root password during first run
mongodb_root_password = ""

# Enable Redis
redis_enabled = true

# Set Redis password during first run
redis_password = ""

# Enable PostgreSQL
postgresql_enabled = true

# Set PostgreSQL password during first run
postgresql_password = "postgresql"

# Enable pgAdmin. WebUI for PostgreSQL
pgadmin_enabled = true

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