locals {
  dashed_domain_name = replace(var.domain_name, ".", "-")
}
#############################################################
# Bitwarden RS
# Ref: https://github.com/dani-garcia/bitwarden_rs
#############################################################
resource "kubernetes_ingress" "bitwarden_rs_ingress" {
  metadata {
    name = "bitwarden-rs-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "bitwarden.${var.domain_name}",
      ]
      secret_name = "bitwarden-${local.dashed_domain_name}"
    }

    backend {
      service_name = "bitwarden-rs-service"
      service_port = 80
    }

    rule {
      host = "bitwarden.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "bitwarden-rs-service"
            service_port = 80
          }
        }

        path {
          path = "/notifications/hub"
          backend {
            service_name = "bitwarden-rs-service"
            service_port = 3012
          }
        }

      }
    }

  }
}


resource "kubernetes_service" "bitwarden_rs_service" {
  metadata {
    name = "bitwarden-rs-service"
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "bitwarden-rs"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "wss"
      port        = 3012
      target_port = 3012
    }

  }
}

resource "kubernetes_stateful_set" "bitwarden_rs" {
  metadata {
    name = "bitwarden-rs"
    labels = {
      app = "bitwarden-rs"
    }
  }

  spec {
    service_name = "bitwarden-rs"
    replicas = 1

    selector {
      match_labels = {
        app = "bitwarden-rs"
      }
    }

    template {
      metadata {
        labels = {
          app = "bitwarden-rs"
        }
      }

      spec {
        container {
          name = "bitwarden-rs"
          image = "bitwardenrs/server:latest"

          env {
            name = "WEBSOCKET_ENABLED"
            value = "true"
          }

          env {
            name = "SIGNUPS_ALLOWED"
            value = "false"
          }

          env {
            name = "DISABLE_ADMIN_TOKEN"
            value = "false"
          }

          env {
            name = "INVITATIONS_ALLOWED"
            value = "false"
          }

          volume_mount {
            name = "bitwarden-rs-data-volume"
            mount_path = "/data"
          }

          port {
            container_port = 80
          }

          port {
            container_port = 3012
          }

        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "bitwarden-rs-data-volume"
      }
      spec {
        storage_class_name = "default"
        access_modes = [
          "ReadWriteMany"
        ]
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}

#############################################################
# Pihole
# Ref: https://github.com/pi-hole/docker-pi-hole/
#############################################################
resource "kubernetes_service" "pihole_dns_lb" {
  metadata {
    name = "pihole-dns-service"
  }
  spec {
    type = "LoadBalancer"

    selector = {
      app = "pihole"
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
  metadata {
    name = "pihole-service"
  }
  spec {
    type = "ClusterIP"

    selector = {
      app = "pihole"
    }

    port {
      name = "pihole-admin-http"
      port = 80
      target_port = 80
    }

    port {
      # Port 443 is to provide a sinkhole for ads that use SSL
      name = "pihole-admin-https"
      port = 443
      target_port = 443
    }

    port {
      port = 53
      target_port = 53
      protocol = "TCP"
      name = "dns-tcp"
    }

    port {
      port = 53
      target_port = 53
      protocol = "UDP"
      name = "dns-udp"
    }
  }
}

resource "kubernetes_ingress" "pihole_ingress" {
  metadata {
    name = "pihole-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/admin"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "pihole.${var.domain_name}",
      ]
      secret_name = "pihole-${local.dashed_domain_name}"
    }

    backend {
      service_name = "pihole-service"
      service_port = 80
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

# Pihole's post installation script
resource "kubernetes_config_map" "pihole_post_init_script" {
  metadata {
    name = "pihole-post-init-script"
  }
  data = {
    "post_init.sh" = file(abspath("../modules/bash/pihole_post_init/post_init.sh"))
  }
}

resource "kubernetes_deployment" "pihole" {

  metadata {
    name = "pihole"
    labels = {
      app = "pihole"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "pihole"
      }
    }
    template {
      metadata {
        labels = {
          app = "pihole"
          name = "pihole"
        }
      }
      spec {
        volume {
          name = "pihole-post-init-script"
          config_map {
            default_mode = "0700"
            name = "pihole-post-init-script"
          }
        }
        container {
          name = "pihole"
          image = "pihole/pihole:latest"
          image_pull_policy = "Always"

          volume_mount {
            mount_path = "/bin/post_init.sh"
            name = "pihole-post-init-script"
            read_only = true
            sub_path = "post_init.sh"
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
            name = "TZ"
            value = var.default_time_zone
          }

          env {
            name = "DNS1"
            value = var.dns_servers[0]
          }

          port {
            container_port = 53
            protocol = "TCP"
            name = "dns-tcp"
          }

          port {
            container_port = 53
            protocol = "UDP"
            name = "dns-udp"
          }

          port {
            container_port = 80
            protocol = "TCP"
            name = "http"
          }

          # Port 443 is to provide a sinkhole for ads that use SSL
          port {
            container_port = 443
            protocol = "TCP"
            name = "https"
          }

        }
      }
    }
  }
}