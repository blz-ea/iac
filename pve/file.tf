#############################################################
# Download Virtual Environment ISO Files
#############################################################
resource "proxmox_virtual_environment_file" "virtio-win" {
    content_type = "iso"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.173-9/virtio-win.iso"
    }

    lifecycle {
        ignore_changes = [
            source_file,
        ]
    }

}

resource "proxmox_virtual_environment_file" "centos-7-x86-64-minimal-1908" {
    content_type = "iso"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "https://mirrors.oit.uci.edu/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso"
    }

    lifecycle {
        ignore_changes = [
            source_file,
        ]
    }

}

resource "proxmox_virtual_environment_file" "ubuntu-18-04-4-server-amd64" {
    content_type = "iso"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "http://cdimage.ubuntu.com/releases/bionic/release/ubuntu-18.04.4-server-amd64.iso"
    }

}

resource "proxmox_virtual_environment_file" "ubuntu-19-10-server-amd64" {
    content_type = "iso"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "http://cdimage.ubuntu.com/releases/eoan/release/ubuntu-19.10-server-amd64.iso"
    }
}

#############################################################
# Download Virtual Environment LXC Container Templates
#############################################################
resource "proxmox_virtual_environment_file" "lxc-ubuntu-19-10-standard-19-10-1-amd64" {
    content_type = "vztmpl"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "http://download.proxmox.com/images/system/ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
    }
}

resource "proxmox_virtual_environment_file" "lxc-ubuntu-18-04-standard-18-04-1-1-amd64" {
    content_type = "vztmpl"

    datastore_id = var.default_data_store_id
    node_name    = local.proxmox_nodes.node1.name

    source_file {
        path = "http://download.proxmox.com/images/system/ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz"
    }
}