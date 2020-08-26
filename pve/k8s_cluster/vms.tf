locals {
  vm_haproxy_ips = { for index, val in proxmox_virtual_environment_vm.haproxy:
    index => val.ipv4_addresses[1][0]
  }

  vm_master_ips = { for index, val in proxmox_virtual_environment_vm.master:
    index => val.ipv4_addresses[1][0]
  }

  vm_worker_ips = { for index, val in proxmox_virtual_environment_vm.worker:
    index => val.ipv4_addresses[1][0]
  }

  wait_for_apt = [
    "sleep 60",
    "while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/{lock,lock-frontend} >/dev/null 2>&1; do sleep 5; done",
    "sleep 5",
  ]

  worker_node_provisioner = [
    "sudo add-apt-repository ppa:gluster/glusterfs-7 -y",
    "sudo apt install glusterfs-client - y",
    "sudo apt install nfs-common -y",
    "sudo apt install ceph-common -y",
  ]

}

resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
  }
}
#############################################################
# Template files
#############################################################
# Kubespray all.yml template #
data "template_file" "kubespray_all" {
  template = file("${path.module}/templates/kubespray_all.tpl")
}

# Kubespray k8s_cluster-cluster.yml template #
data "template_file" "kubespray_k8s_cluster" {
  template = file("${path.module}/templates/kubespray_k8s_cluster.tpl")

  vars = {
    kube_version        = var.k8s_version
    kube_network_plugin = var.k8s_network_plugin
  }
}

# HAProxy hostname and ip list template #
data "template_file" "haproxy_hosts" {
  count    = length(local.vm_haproxy_ips)
  template = file("${path.module}/templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-haproxy-${count.index}"
    host_ip  = lookup(local.vm_haproxy_ips, count.index)
  }
}

# Kubespray master hostname and ip list template #
data "template_file" "kubespray_hosts_master" {
  count    = length(local.vm_master_ips)
  template = file("${path.module}/templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-master-${count.index}"
    host_ip  = lookup(local.vm_master_ips, count.index)
  }
}

# Kubespray worker hostname and ip list template #
data "template_file" "kubespray_hosts_worker" {
  count    = length(local.vm_worker_ips)
  template = file("${path.module}/templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-worker-${count.index}"
    host_ip  = lookup(local.vm_worker_ips, count.index)
  }
}

# HAProxy hostname list template #
data "template_file" "haproxy_hosts_list" {
  count    = length(local.vm_haproxy_ips)
  template = file("${path.module}/templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-haproxy-${count.index}"
  }
}

# Kubespray master hostname list template #
data "template_file" "kubespray_hosts_master_list" {
  count    = length(local.vm_master_ips)
  template = file("${path.module}/templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-master-${count.index}"
  }
}

# Kubespray worker hostname list template #
data "template_file" "kubespray_hosts_worker_list" {
  count    = length(local.vm_worker_ips)
  template = file("${path.module}/templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-worker-${count.index}"
  }
}

# HAProxy template #
data "template_file" "haproxy" {
  template = file("${path.module}/templates/haproxy.tpl")

  vars = {
    bind_ip = var.vm_haproxy_vip
  }
}

# HAProxy server backend template #
data "template_file" "haproxy_backend" {
  count    = length(local.vm_master_ips)
  template = file("${path.module}/templates/haproxy_backend.tpl")

  vars = {
    prefix_server     = var.vm_name_prefix
    backend_server_ip = lookup(local.vm_master_ips, count.index)
    count             = count.index
  }
}

# Keepalived master template #
data "template_file" "keepalived_master" {
  template = file("${path.module}/templates/keepalived_master.tpl")

  vars = {
    virtual_ip = var.vm_haproxy_vip
  }
}

# Keepalived slave template #
data "template_file" "keepalived_slave" {
  template = file("${path.module}/templates/keepalived_slave.tpl")

  vars = {
    virtual_ip = var.vm_haproxy_vip
  }
}


#############################################################
# Local Files
#############################################################

# Create Kubespray all.yml configuration file from Terraform template #
resource "local_file" "kubespray_all" {
  content  = data.template_file.kubespray_all.rendered
  filename = "${path.module}/config/group_vars/all.yml"
}

# Create Kubespray k8s_cluster-cluster.yml configuration file from Terraform template #
resource "local_file" "kubespray_k8s_cluster" {
  content  = data.template_file.kubespray_k8s_cluster.rendered
  filename = "${path.module}/config/group_vars/k8s-cluster.yml"
}

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "kubespray_hosts" {
  content  = <<-EOF
  ${join("\n", data.template_file.haproxy_hosts.*.rendered)}
  ${join("\n", data.template_file.kubespray_hosts_master.*.rendered)}
  ${join("\n", data.template_file.kubespray_hosts_worker.*.rendered)}
  [haproxy]
  ${join("\n", data.template_file.haproxy_hosts_list.*.rendered)}
  [kube-master]
  ${join("\n", data.template_file.kubespray_hosts_master_list.*.rendered)}
  [etcd]
  ${join("\n", data.template_file.kubespray_hosts_master_list.*.rendered)}
  [kube-node]
  ${join("\n", data.template_file.kubespray_hosts_worker_list.*.rendered)}
  [k8s-cluster:children]
  kube-master
  kube-node
  EOF
  filename = "${path.module}/config/hosts.ini"
}

# Create HAProxy configuration from Terraform templates #
resource "local_file" "haproxy" {
  content  = <<-EOF
  ${data.template_file.haproxy.rendered}
  ${join("\n", data.template_file.haproxy_backend.*.rendered)}
  EOF
  filename = "${path.module}/config/haproxy.cfg"
}

# Create Keepalived master configuration from Terraform templates #
resource "local_file" "keepalived_master" {
  content  = data.template_file.keepalived_master.rendered
  filename = "${path.module}/config/keepalived-master.cfg"
}

# Create Keepalived slave configuration from Terraform templates #
resource "local_file" "keepalived_slave" {
  content  = data.template_file.keepalived_slave.rendered
  filename = "${path.module}/config/keepalived-slave.cfg"
}

# Modify the permission on the config directory
resource "null_resource" "config_permission" {
  provisioner "local-exec" {
    command     = "chmod -R 700 ${path.module}/config"
    on_failure  = continue
  }

  depends_on = [
    local_file.haproxy,
    local_file.kubespray_hosts,
    local_file.kubespray_k8s_cluster,
    local_file.kubespray_all,
    null_resource.depends_on,
  ]
}

# Execute HAProxy Ansible playbook #
resource "null_resource" "haproxy_install" {
  count = var.action == "create" ? 1 : 0

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/haproxy && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_provisioner_user} -v haproxy.yml --forks=1"
    environment = {
        ANSIBLE_FORCE_COLOR = "True"
    }
  }

  depends_on = [
    local_file.kubespray_hosts,
    local_file.haproxy,
    proxmox_virtual_environment_vm.haproxy,
    null_resource.depends_on,
  ]
}

# Execute create Kubespray Ansible playbook #
resource "null_resource" "kubespray_create" {
  count = var.action == "create" ? 1 : 0

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_provisioner_user} -e \"kube_version=${var.k8s_version}\" -v cluster.yml"
    environment = {
        ANSIBLE_FORCE_COLOR = "True"
    }
  }

  depends_on = [
    local_file.kubespray_hosts,
    null_resource.kubespray_download,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_virtual_environment_vm.haproxy,
    proxmox_virtual_environment_vm.master,
    proxmox_virtual_environment_vm.master,
    null_resource.depends_on,
  ]

}

# Execute scale Kubespray Ansible playbook #
resource "null_resource" "kubespray_add" {
  count = var.action == "add_worker" ? 1 : 0

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_provisioner_user} -e \"kube_version=${var.k8s_version}\" -v scale.yml"
    environment = {
      ANSIBLE_FORCE_COLOR = "True"
    }
  }

  depends_on = [
    local_file.kubespray_hosts,
    null_resource.kubespray_download,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_virtual_environment_vm.haproxy,
    proxmox_virtual_environment_vm.master,
    proxmox_virtual_environment_vm.master,
    null_resource.depends_on,
  ]

}

# Execute upgrade Kubespray Ansible playbook #
resource "null_resource" "kubespray_upgrade" {
  count = var.action == "upgrade" ? 1 : 0

  triggers = {
    ts = timestamp()
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/kubespray && sudo pip3 install -r requirements.txt"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_provisioner_user} -e \"kube_version=${var.k8s_version}\" -v upgrade-cluster.yml"
    environment = {
      ANSIBLE_FORCE_COLOR = "True"
    }
  }

  depends_on = [
    local_file.kubespray_hosts,
    null_resource.kubespray_download,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_virtual_environment_vm.haproxy,
    proxmox_virtual_environment_vm.master,
    proxmox_virtual_environment_vm.master,
    null_resource.depends_on,
  ]

}

# Create the local admin.conf kubectl configuration file #
resource "null_resource" "kubectl_configuration" {
  provisioner "local-exec" {
    command = "ansible -i ${lookup(local.vm_master_ips, 0)}, -b -u ${var.vm_provisioner_user} -m fetch -a 'src=/etc/kubernetes/admin.conf dest=${path.module}/config/admin.conf flat=yes' all"
  }

  provisioner "local-exec" {
    command     = "sed 's/lb-apiserver.kubernetes.local/${var.vm_haproxy_vip}/g' ${path.module}/config/admin.conf | tee ${path.module}/config/admin.conf.new && mv ${path.module}/config/admin.conf.new ${path.module}/config/admin.conf && chmod 700 ${path.module}/config/admin.conf"
    on_failure  = continue
  }

  provisioner "local-exec" {
    command     = "chmod 600 ${path.module}/config/admin.conf"
    on_failure  = continue
  }

  depends_on = [
    null_resource.kubespray_create,
    null_resource.depends_on,
  ]

}

# Clone Kubespray repository #
resource "null_resource" "kubespray_download" {
  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible/kubespray && sudo pip3 install -r requirements.txt"
  }
}

#############################################################
#VMS
#############################################################

# HAProxy Nodes
resource "proxmox_virtual_environment_vm" "haproxy" {
  name        = "${var.vm_name_prefix}-haproxy-${count.index}"
  description = "Managed by Terraform"
  started     = true
  count       = var.vm_haproxy_count

  clone {
    vm_id = var.vm_haproxy_clone_id
  }

  cpu {
    cores   = var.vm_haproxy_cpu_cores
    sockets = var.vm_haproxy_cpu_sockets
  }

  node_name = var.vm_haproxy_proxmox_node_name
  pool_id   = var.vm_haproxy_proxmox_pool_id

  agent {
    enabled = true
  }

  memory {
    dedicated = var.vm_haproxy_ram_dedicated
    floating  = var.vm_haproxy_ram_floating
  }

  network_device {}

  initialization {
    datastore_id = var.vm_haproxy_proxmox_datastore_id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = var.vm_provisioner_user_public_keys
      password = var.vm_provisioner_user_password
      username = var.vm_provisioner_user
    }

    dns {
      domain = var.vm_domain
      server = var.vm_dns
    }
  }

  operating_system {
    type = var.vm_os_type
  }

  vga {
    type = var.vm_vga_type
  }

  provisioner "remote-exec" {
    connection {
      type     = var.vm_provisioner_type
      user     = var.vm_provisioner_user
      host     = self.ipv4_addresses[1][0]
    }

    inline = local.wait_for_apt
  }
}

# Master Nodes
resource "proxmox_virtual_environment_vm" "master" {
  name        = "${var.vm_name_prefix}-master-${count.index}"
  description = "Managed by Terraform"
  started     = true
  count       = var.vm_master_count

  clone {
    vm_id     = var.vm_master_clone_id
  }

  cpu {
    cores     = var.vm_master_cpu_cores
    sockets   = var.vm_master_cpu_sockets
  }

  node_name   = var.vm_master_proxmox_node_name
  pool_id     = var.vm_master_proxmox_pool_id

  agent {
    enabled = true
  }

  memory {
    dedicated = var.vm_master_ram_dedicated
    floating = var.vm_master_ram_floating
  }

  network_device {}

  initialization {
    datastore_id = var.vm_master_proxmox_datastore_id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = var.vm_provisioner_user_public_keys
      password = var.vm_provisioner_user_password
      username = var.vm_provisioner_user
    }

    dns {
      domain = var.vm_domain
      server = var.vm_dns
    }
  }

  operating_system {
    type = var.vm_os_type
  }

  vga {
    type = var.vm_vga_type
  }

  provisioner "remote-exec" {

    connection {
      type     = var.vm_provisioner_type
      user     = var.vm_provisioner_user
      host     = self.ipv4_addresses[1][0]
    }

    inline = local.wait_for_apt
  }

}

# Worker Nodes
resource "proxmox_virtual_environment_vm" "worker" {
  name        = "${var.vm_name_prefix}-worker-${count.index}"
  description = "Managed by Terraform"
  started     = true
  count       = var.vm_worker_count

  clone {
    vm_id   = var.vm_worker_clone_id
  }

  cpu {
    cores   = var.vm_worker_cpu_cores
    sockets = var.vm_worker_cpu_sockets
  }

  node_name = var.vm_worker_proxmox_node_name
  pool_id   = var.vm_worker_proxmox_pool_id

  agent {
    enabled = true
  }

//  disk {
//    datastore_id = "local-lvm"
//    size = 30 # Should be the same as copy
//  }

  memory {
    dedicated = var.vm_worker_ram_dedicated
    floating  = var.vm_worker_ram_floating
  }

  network_device {}

  initialization {
    datastore_id = var.vm_worker_proxmox_datastore_id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = var.vm_provisioner_user_public_keys
      password = var.vm_provisioner_user_password
      username = var.vm_provisioner_user
    }

    dns {
      domain = var.vm_domain
      server = var.vm_dns
    }
  }

  operating_system {
    type = var.vm_os_type
  }

  vga {
    type = var.vm_vga_type
  }

  provisioner "remote-exec" {
    connection {
      type     = var.vm_provisioner_type
      user     = var.vm_provisioner_user
      host     = self.ipv4_addresses[1][0]
    }

    inline = local.wait_for_apt
  }

  provisioner "remote-exec" {
    connection {
      type     = var.vm_provisioner_type
      user     = var.vm_provisioner_user
      host     = self.ipv4_addresses[1][0]
    }

    inline = local.worker_node_provisioner
  }

}