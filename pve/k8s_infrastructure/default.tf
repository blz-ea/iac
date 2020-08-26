#############################################################
# Pihole
# Ref: https://github.com/pi-hole/docker-pi-hole/
#############################################################
resource "kubernetes_ingress" "pihole_ingress" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target"   = "/admin"
      "nginx.ingress.kunernetes.io/ssl-redirect"      = "false"
      "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"

      "nginx.ingress.kubernetes.io/auth-url"          = "https://forwardauth.${var.domain_name}/verify?uri=$scheme://$host$request_uri"
      "nginx.ingress.kubernetes.io/auth-signin"       = "https://forwardauth.${var.domain_name}?uri=$scheme://$host$request_uri"

    }
  }

  spec {
    tls {
      hosts = [
        "pihole.${var.domain_name}",
      ]
      secret_name = "pihole-${local.dashed_domain_name}"
    }

    rule {
      host = "pihole.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "pihole-service"
            service_port = 80
          }
        }
      }
    }

  }
}

resource "kubernetes_service" "pihole_dns_lb" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-dns-service"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/name" = "pihole"
    }

    port {
      port = 53
      target_port = 53
      protocol = "UDP"
      name = "dns-tcp"
    }
  }
}

resource "kubernetes_service" "pihole-service" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-service"
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "pihole"
    }

    port {
      name        = "pihole-admin-http"
      port        = 80
      target_port = 80
    }

    port {
      # Port 443 is to provide SSL sinkhole
      name        = "pihole-admin-https"
      port        = 443
      target_port = 443
    }

    port {
      port        = 53
      target_port = 53
      protocol    = "TCP"
      name        = "dns-tcp"
    }

    port {
      port        = 53
      target_port = 53
      protocol    = "UDP"
      name        = "dns-udp"
    }
  }
}

# Pihole's post installation script
resource "kubernetes_config_map" "pihole_post_init_script" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-post-init-script"
  }

  data = {
    "post_init.sh" = file(abspath("../modules/bash/pihole_post_init/post_init.sh"))
  }
}

resource "kubernetes_deployment" "pihole" {
  count = var.pihole_enabled ? 1 : 0

  metadata {
    name = "pihole"

    labels = {
      "app.kubernetes.io/name" = "pihole"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "pihole"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "pihole"
        }
      }
      spec {
        volume {
          name = "pihole-post-init-script"
          config_map {
            default_mode = "0700"
            name         = "pihole-post-init-script"
          }
        }
        container {
          name              = "pihole"
          image             = "pihole/pihole:latest"
          image_pull_policy = "Always"

          volume_mount {
            mount_path  = "/bin/post_init.sh"
            name        = "pihole-post-init-script"
            read_only   = true
            sub_path    = "post_init.sh"
          }

          lifecycle {
            post_start {
              exec {
                command = [
                  "/bin/post_init.sh"
                ]
              }
            }
          }

          env {
            name  = "TZ"
            value = var.default_time_zone
          }

          env {
            name  = "DNS1"
            value = var.dns_servers[0]
          }

          env {
            name  = "DNS2"
            value = length(var.dns_servers) > 1 ? var.dns_servers[1] : "127.0.0.1"
          }

          port {
            container_port  = 53
            protocol        = "TCP"
            name            = "dns-tcp"
          }

          port {
            container_port  = 53
            protocol        = "UDP"
            name            = "dns-udp"
          }

          port {
            container_port  = 80
            protocol        = "TCP"
            name            = "http"
          }

          # Port 443 is to provide a sinkhole for ads that use SSL
          port {
            container_port  = 443
            protocol        = "TCP"
            name            = "https"
          }

        }
      }
    }
  }
}