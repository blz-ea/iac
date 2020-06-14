#
# Download Virtual Environment ISO Files
#
resource "proxmox_virtual_environment_file" "virtio-win" {
    content_type = "iso"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.173-9/virtio-win.iso"
    }
}

resource "proxmox_virtual_environment_file" "centos-7-x86-64-minimal-1908" {
    content_type = "iso"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "http://mirror.atlanticmetro.net/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso"
    }
}

resource "proxmox_virtual_environment_file" "ubuntu-18-04-4-server-amd64" {
    content_type = "iso"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "http://cdimage.ubuntu.com/releases/bionic/release/ubuntu-18.04.4-server-amd64.iso"
    }
}

resource "proxmox_virtual_environment_file" "ubuntu-19-10-server-amd64" {
    content_type = "iso"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "http://cdimage.ubuntu.com/releases/eoan/release/ubuntu-19.10-server-amd64.iso"
    }
}