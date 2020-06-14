#
# Download Virtual Environment LXC Container Templates 
#
resource "proxmox_virtual_environment_file" "ubuntu-19-10-standard-19-10-1-amd64" {
    content_type = "vztmpl"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "http://download.proxmox.com/images/system/ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
    }
}

resource "proxmox_virtual_environment_file" "ubuntu-18-04-standard-18-04-1-1-amd64" {
    content_type = "vztmpl"

    datastore_id = "nfs-ax"
    node_name    = "pve"

    source_file {
        path = "http://download.proxmox.com/images/system/ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz"
    }
}
