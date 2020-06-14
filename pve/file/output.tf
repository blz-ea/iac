# LXC Container Templates
output "vztmpl" {
  value = {
      ubuntu-18-04-standard-18-04-1-1-amd64 = proxmox_virtual_environment_file.ubuntu-18-04-standard-18-04-1-1-amd64,
      ubuntu-19-10-standard-19-10-1-amd64 = proxmox_virtual_environment_file.ubuntu-19-10-standard-19-10-1-amd64
  }
}

# ISO images
output "iso" {
    value = {
        ubuntu-18-04-4-server-amd64 = proxmox_virtual_environment_file.ubuntu-18-04-4-server-amd64,
        ubuntu-19-10-server-amd64 = proxmox_virtual_environment_file.ubuntu-19-10-server-amd64,
        centos-7-x86-64-minimal-1908 = proxmox_virtual_environment_file.centos-7-x86-64-minimal-1908
        virtio-win = proxmox_virtual_environment_file.virtio-win
    }
}