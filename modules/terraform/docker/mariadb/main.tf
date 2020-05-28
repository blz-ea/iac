locals {
  container_name = var.container_name
  
  default_labels = []

  default_command = [
    "--character-set-server=utf8",
    "--collation-server=utf8_unicode_ci",
  ]
  
  default_env = []
}

# Passed in dependencies
resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
  }
}

resource "docker_image" "image" {
  name = "mariadb:${var.image_version}"

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

  volumes {
    volume_name     = docker_volume.volume.name
    container_path  = "/var/lib/mysql"
    read_only       = false
  }

  command = concat(["mysqld"], distinct(concat(var.command, local.default_command)))

  env = distinct(concat(var.env, local.default_env))

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

  depends_on = [
    null_resource.depends_on
  ]

}
