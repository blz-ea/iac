#############################################################
# Packer Templates
#############################################################
locals {
  # Default configuration that applies to all Packer templates
  packer_default_cfg = {
    PKR_VAR_proxmox_hostname  = var.proxmox_api_url
    PKR_VAR_proxmox_username  = var.proxmox_api_username
    PKR_VAR_proxmox_password  = var.proxmox_api_password
    PKR_VAR_proxmox_node      = local.proxmox_nodes.node1.name

    PKR_VAR_vm_cores          = var.packer_default_cores
    PKR_VAR_vm_storage_pool   = var.default_vm_store_id

    PKR_VAR_vm_username       = var.user_name
    PKR_VAR_vm_user_password  = var.user_password
    PKR_VAR_vm_time_zone      = var.default_time_zone
  }

  packer_centos_7 = {
    vm_id     = 4003
    iso_file  = proxmox_virtual_environment_file.centos-7-x86-64-minimal-1908.id
  }

  packer_ubuntu_bionic = {
    vm_id     = 4002
    iso_file  = proxmox_virtual_environment_file.ubuntu-18-04-4-server-amd64.id
  }

}
# TODO: Add `null_resource` (with on_destroy method) that will delete template from Proxmox node before creating new one

#############################################################
# Packer Templates - CentOS 7
#############################################################
resource "null_resource" "packer_centos_7" {
  provisioner "local-exec" {
    command     = "packer build ${path.module}/templates/centos-7"
    environment = merge(local.packer_default_cfg, {
      PKR_VAR_vm_id       = local.packer_centos_7.vm_id
      PKR_VAR_vm_iso_file = local.packer_centos_7.iso_file
    })
  }

  triggers = {
    default_config  = yamlencode(local.packer_default_cfg)
    config          = yamlencode(local.packer_centos_7)
    sources_hash    = sha1(file("${path.module}/templates/centos-7/sources.pkr.hcl"))
    http_seed_hash  = sha1(file("${path.module}/templates/centos-7/http/preseed.cfg"))
  }

  depends_on = [
    proxmox_virtual_environment_file.centos-7-x86-64-minimal-1908
  ]
}

#############################################################
# Packer Templates- Ubuntu Bionic 18.04
#############################################################
resource "null_resource" "packer_ubuntu_bionic" {

  provisioner "local-exec" {
    command     = "packer build ${path.module}/templates/ubuntu-18.04"
    environment = merge(local.packer_default_cfg, {
      PKR_VAR_vm_id       = local.packer_ubuntu_bionic.vm_id
      PKR_VAR_vm_iso_file = local.packer_ubuntu_bionic.iso_file
    })
  }

  triggers = {
    default_config  = yamlencode(local.packer_default_cfg)
    config          = yamlencode(local.packer_ubuntu_bionic)
    sources_hash    = sha1(file("${path.module}/templates/ubuntu-18.04/sources.pkr.hcl"))
    http_seed_hash  = sha1(file("${path.module}/templates/ubuntu-18.04/http/preseed.cfg"))
  }

  depends_on = [
    proxmox_virtual_environment_file.ubuntu-18-04-4-server-amd64
  ]
}
