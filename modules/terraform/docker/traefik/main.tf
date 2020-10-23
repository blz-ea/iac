locals {
  container_name      = var.container_name
  
  default_labels = [
    "traefik.enable=true",
  ]

}

# Passed in dependencies
resource "null_resource" "depends_on" {
  triggers = {
    depends_on = join("", var.dependencies)
  }
}

resource "docker_image" "image" {
  name = "traefik:${var.image_version}"

  depends_on = [
    null_resource.depends_on
  ]
}

resource "docker_volume" "volume" {
  name = "${local.container_name}_volume"
}

resource "docker_container" "container" {
  name = local.container_name
  image = docker_image.image.latest
  restart = "always"

  volumes {
    volume_name     = docker_volume.volume.name
    container_path  = "/letsencrypt/"
    read_only       = false
  }

  volumes {
    host_path       = "/var/run/docker.sock"
    container_path  = "/var/run/docker.sock"
    read_only       = false
  }

  upload {
     content       = yamlencode(var.file_cfg_dynamic)
     source_hash   = sha1(yamlencode(var.file_cfg_dynamic))
     file          = "/etc/conf.d/file_cfg.yml"
  }

  upload {
     content       = yamlencode(var.file_cfg_static)
     source_hash   = sha1(yamlencode(var.file_cfg_static))
     file          = "/etc/traefik/traefik.yml"
  }

  env = var.env

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = element(split(":", ports.value), 0)
      external = element(split(":", ports.value), 1)
    }
  }

  dynamic "labels" {
    for_each = distinct(concat(var.labels,local.default_labels))
    content {
      label = element(split("=", labels.value), 0)
      value = element(split("=", labels.value), 1)
    }
  }

  dynamic "networks_advanced" {
    for_each = var.networks_advanced
    content {
      name = networks_advanced.value
    }
  }

  lifecycle {
    ignore_changes = [
      labels,
      env,
    ]
  }

  depends_on = [
    null_resource.depends_on
  ]

}
