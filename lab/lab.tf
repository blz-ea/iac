locals {
    vars_folder_path = abspath("../vars/")
}

# Import varaibles related
module "vars" {
    source = "../modules/terraform/vars"
    # Folder containing variables
    vars_folder = "${local.vars_folder_path}"

    # Variable iles to import
    input_var_files = {
        # Environment name/Workspace name = "file.yml"
        prod = "prod.yml"
    }
}

provider "proxmox" {
    alias = "pve"
    pm_tls_insecure = module.vars.workspace.proxmox.auth.tls_insecure
    pm_api_url = module.vars.workspace.proxmox.auth.api_url
    pm_user = module.vars.workspace.proxmox.auth.username
    pm_password = module.vars.workspace.proxmox.auth.password
    pm_otp = module.vars.workspace.proxmox.auth.otp
}

module "proxmox-lxc" {
    providers = {
        proxmox = proxmox.pve
    }

    source = "../modules/terraform/proxmox-lxc"
    hostname = "pihole.devset.app"
    password = "${module.vars.workspace.proxmox.lxc.pihole.password}"
    ostemplate = "local:vztmpl/ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
    mounts = [
        {
            volume = "/mnt"
            mp = "/mnt"
        }
    ]
}
