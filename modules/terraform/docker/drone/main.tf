locals {
  container_name = var.container_name
  default_labels = [
    "org.label-schema.build-date=2020-04-17T16:08:13Z",
    "org.label-schema.schema-version=1.0",
    "org.label-schema.vcs-ref=d1a2f2174db51f4011ec4ab212ad4704c71c751e",
    "org.label-schema.vcs-url=https://github.com/drone/drone.git",
  ]
  default_env = [
    "DRONE_DATABASE_DATASOURCE=/data/database.sqlite",
    "DRONE_DATABASE_DRIVER=sqlite3",
    "DRONE_DATADOG_ENABLED=true",
    "DRONE_DATADOG_ENDPOINT=https://stats.drone.ci/api/v1/series",
    "DRONE_RUNNER_ARCH=amd64",
    "DRONE_RUNNER_OS=linux",
    "DRONE_SERVER_PORT=:80",
    "GODEBUG=netdns=go",
    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "XDG_CACHE_HOME=/data",
  ]
}

# Passed in dependencies
resource "null_resource" "depends_on" {
  triggers = {
    depends_on = join("", var.dependencies)
  }
}

resource "docker_image" "image" {
  name = "drone/drone"

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
    container_path  = "/data"
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

  dynamic "labels" {
    for_each = distinct(concat(var.labels, local.default_labels))
    content {
      label = element(split("=", labels.value), 0)
      value = element(split("=", labels.value), 1)
    }
  }

  depends_on = [
    null_resource.depends_on
  ]
  
  dynamic "networks_advanced" {
    for_each = var.networks_advanced
    content {
      name = networks_advanced.value
    }
  }

}