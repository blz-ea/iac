#############################################################
# Kubernetes variables
#############################################################

# Git repository to clone Kubespray from
k8s_kubespray_url = "https://github.com/kubernetes-sigs/kubespray.git"

# Kubespray repository branch/release that will be used to deploy Kubernetes
k8s_kubespray_version = "master"

# Kubernetes version that will be deployed
k8s_version = "v1.18.5"

# The overlay network plugin used by the Kubernetes cluster
k8s_network_plugin = "calico"

#############################################################
# Virtual machines variables
#############################################################

# Username used to SSH to the virtual machines
vm_provisioner_user = "deploy"

# List of provisioning user's SSH public keys
vm_provisioner_user_public_keys = ["ssh-rsa ..."]

# The prefix to add to the names of the virtual machines
vm_name_prefix = "k8s-"

# DNS server that will be used by the virtual machines (e.g 192.168.1.1)
vm_dns = ""

# The domain name used by the virtual machines
vm_domain = ""

#############################################################
# HAProxy load balancer variables
#############################################################

# IP address that will be used by keepalived
vm_haproxy_vip = ""

# Number of HAProxy virtual machines
vm_haproxy_count = 2

# Proxmox node name
vm_haproxy_proxmox_node_name = ""

# Proxmox pool id
vm_haproxy_proxmox_pool_id = ""

# VM id to clone from
vm_haproxy_clone_id = 0

# Number of CPU cores
vm_haproxy_cpu_cores = 2

# Number of CPU sockets
vm_haproxy_cpu_sockets = 1

# Amount of dedicated RAM
vm_haproxy_ram_dedicated = 2048

# Amount of floating RAM
vm_haproxy_ram_floating = 1536

# Where on Proxmox VM should be stored (datastore id)
vm_haproxy_proxmox_datastore_id = "local-lvm"

#############################################################
# Master node variables
#############################################################

# Number of HAProxy virtual machines
vm_master_count = 3

# Proxmox node name
vm_master_proxmox_node_name = ""

# Proxmox pool id
vm_master_proxmox_pool_id = ""

# VM template id to clone from
vm_master_clone_id = 0

# Number of CPU cores
vm_master_cpu_cores = 2

# Number of CPU sockets
vm_master_cpu_sockets = 1

# Amount of dedicated RAM
vm_master_ram_dedicated = 3000

# Amount of floating RAM
vm_master_ram_floating = 2048

# Where on Proxmox VM should be stored (datastore id)
vm_master_proxmox_datastore_id = "local-lvm"

#############################################################
# Worker node variables
#############################################################

# Number of HAProxy virtual machines
vm_master_count = 3

# Proxmox node name
vm_master_proxmox_node_name = ""

# Proxmox pool id
vm_master_proxmox_pool_id = ""

# VM id to clone from
vm_master_clone_id = 0

# Number of CPU cores
vm_master_cpu_cores = 2

# Number of CPU sockets
vm_master_cpu_sockets = 1

# Amount of dedicated RAM
vm_master_ram_dedicated = 2048

# Amount of floating RAM
vm_master_ram_floating = 1536

# Where on Proxmox VM should be stored (datastore id)
vm_master_proxmox_datastore_id = "local-lvm"