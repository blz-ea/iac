locals {
  container_name = var.container_name
  default_env = [
    "DRONE_RPC_PROTO=https",
    "DRONE_PLATFORM_ARCH=amd64",
    "DRONE_PLATFORM_OS=linux",
    "GODEBUG=netdns=go",
    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  ]
}

# Passed in dependencies
resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
  }
}

resource "docker_image" "image" {
  name = "drone/drone-runner-docker"

  depends_on = [
    null_resource.depends_on
  ]
}

resource "docker_container" "container" {
  name = local.container_name
  image = docker_image.image.latest

  volumes {
    host_path       = "/var/run/docker.sock"
    container_path  = "/var/run/docker.sock"
    read_only       = false
  }

  env = distinct(concat(var.env, local.default_env))

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = element(split(":", ports.value), 0)
      external = element(split(":", ports.value), 1)
    }
  }

  depends_on = [
    null_resource.depends_on
  ]

}