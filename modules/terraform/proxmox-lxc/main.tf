# BUG: On Change container does not reboot or recreate
resource "proxmox_lxc" "lxc_container" {
    # BUG: ssh_public_keys only allowed during container initialization?
    # ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDepbcLQSCHyHJIzCor/UDd31lQB1blgU6zfB7ctiNZoRDFIuKSdwFR3HiRa0xIM9uZkckee+XKsx7VhphZ1NYMfa7kuwWgtvEeePAkmrpLUz/gP7MHofsC8Pb7sgoGYPZgBST4WL+q3o+RA/mMVSfNl79CZTse+3rtFrZfXFCub5ZKpnzrPaF3eKgeCCV6LwgZRUeAApswo1O+gLE0hLlNQBA8P+cLAe4ukN/nTqh5cnn9REbMLNBtrjINfpwzvl5DCTtvHzgOJQQn1mP2O4dG5pqy2Y2hdYEGD5l0T/2kBYgMFziMiDjJEf8oPsSX/ZqdI1woJVhpg3K9GVi/AmWV alex.kulikovskikh@gmail.com"
    
    features {
        nesting = true
    }
    hostname = var.hostname
    memory = var.memory
    network {
        name = var.network.name
        bridge = var.network.bridge
        ip = var.network.ip
        ip6 = var.network.ip6
    }
    # BUG: Mountpoint allowed only on created containers
    # BUG: Container remove does not remove it from server
    # dynamic "mountpoint" {
    #     for_each = var.mounts
    #     content {
    #         volume = mountpoint.value["volume"]
    #         mp = mountpoint.value["mp"]
    #     }
    # }
    ostemplate = var.ostemplate
    password = var.password
    storage = var.storage
    target_node = var.target_node
    unprivileged = var.unprivileged
    start = var.start
    onboot = var.onboot
}
