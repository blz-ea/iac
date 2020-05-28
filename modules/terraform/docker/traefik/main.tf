locals {
  container_name      = var.container_name
  
  default_labels = [
    "org.opencontainers.image.description=A modern reverse-proxy", # <- added by traefik
    "org.opencontainers.image.documentation=https://docs.traefik.io",
    "org.opencontainers.image.title=Traefik",  
    "org.opencontainers.image.url=https://traefik.io",
    "org.opencontainers.image.vendor=Containous",
    "org.opencontainers.image.version=v2.2.1",
    "traefik.enable=true",
    # Global http to https redirect
    "traefik.http.middlewares.https-redirect.redirectScheme.scheme=https",
    "traefik.http.routers.redirect.entryPoints=http",
    "traefik.http.routers.redirect.rule=hostregexp(`{host:.+}`)",
    "traefik.http.routers.redirect.middlewares=https-redirect",
    "traefik.http.routers.redirect.service=noop@internal",
    "traefik.http.routers.redirect.priority=1",
  ]

  default_command = [
    "--log.level=ERROR",
    "--global.sendAnonymousUsage=false",
    "--serversTransport.insecureSkipVerify=true",
    "--accessLog.bufferingSize=100",
    "--api.dashboard=true",

    "--metrics=true",
    "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0",
    "--metrics.prometheus.addEntryPointsLabels=true",
    "--metrics.prometheus.addServicesLabels=true",
    "--metrics.prometheus.manualRouting=true",
  ]
  
  default_env = [
    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", # <- added by traefik
  ]
}

# Passed in dependencies
resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
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

  # upload {
  #   content       = templatefile("${path.module}/traefik.yml.tpl", {})
  #   source_hash   = sha1(templatefile("${path.module}/traefik.yml.tpl", {}))
  #   file          = "/etc/traefik/traefik.yml"
  # }

  command = concat(["traefik"], distinct(concat(var.command, local.default_command)))

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
