#############################################################
# Kubernetes variables
#############################################################

# IP range that Metallb will use for Load Balancers
metallb_ip_range = "192.168.1.100-192.168.1.200"

#############################################################
# Domain variables
#############################################################

# Cloudflare API token
cloudflare_api_token = ""

# Cloudflare account email
cloudflare_account_email = "example@domain.com"

# Zone name
cloudflare_zone_name = "example.com"

#############################################################
# Storage variables
#############################################################
# NFS Server
# Enables NFS Server as default Storage Class provisioner
nfs_default_storage_class = false

# NFS server IP/Name
nfs_server_address = "192.168.1.1"

# List of Gluster cluster endpoints
gluster_cluster_endpoints = ["192.168.1.1", "192.168.1.2"]