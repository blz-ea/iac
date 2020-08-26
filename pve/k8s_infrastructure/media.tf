locals {
  media_namespace             = kubernetes_namespace.media.metadata.0.name
}

resource "kubernetes_namespace" "media" {
  metadata {
    name = "media"

    labels = {
      "app.kubernetes.io/name"      = "media"
      "app.kubernetes.io/component" = "htpc"
    }
  }
}

#############################################################
# Radarr
# Ref: https://github.com/linuxserver/docker-radarr
#############################################################
resource "kubernetes_ingress" "radarr_ingress" {
  count = var.radarr_enabled ? 1 : 0
  metadata {
    name = "radarr-ingress"
    namespace = local.media_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "radarr.${var.domain_name}",
      ]
      secret_name = "radarr--${local.dashed_domain_name}"
    }

    backend {
      service_name = "radarr-service"
      service_port = 80
    }

    rule {
      host = "radarr.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "radarr-service"
            service_port = 80
          }
        }

      }
    }

  }
}

resource "kubernetes_service" "radarr_service" {
  count = var.radarr_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name = "radarr-service"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "radarr"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 7878
    }

  }
}

resource "kubernetes_stateful_set" "radarr" {
  count = var.radarr_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name      = "radarr"
    labels = {
      "app.kubernetes.io/name" = "radarr"
    }
  }

  spec {
    service_name  = "radarr"
    replicas      = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "radarr"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"          = "radarr"
          "app.kubernetes.io/allow-access"  = "torrent-client"
          "app.kubernetes.io/part-of"       = "htpc"
        }
      }

      spec {
        container {
          name = "radarr"
          image = "linuxserver/radarr"

          env {
            name = "PUID"
            value = "1000"
          }

          env {
            name = "PGID"
            value = "1000"
          }

          env {
            name = "TZ"
            value = var.default_time_zone
          }

          port {
            container_port = 7878
          }

          volume_mount {
            name = "radarr-data-volume"
            mount_path = "/config"
          }

          volume_mount {
            mount_path = "/mnt/local"
            name = "nfs-media"
          }

        }

        volume {
          name = "radarr-data-volume"
          persistent_volume_claim {
            claim_name = "radarr-data-volume"
          }
        }

        volume {
          name = "nfs-media"
          nfs {
            path = "/mnt/local/media"
            server = var.nfs_server_address
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "radarr-data-volume"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "7Gi"
          }
        }
      }
    }

  }

}

#############################################################
# Sonarr
# Ref: https://github.com/linuxserver/docker-sonarr
#############################################################
resource "kubernetes_ingress" "sonarr_ingress" {
  count = var.sonarr_enabled ? 1 : 0

  metadata {
    name        = "sonarr-ingress"
    namespace   = local.media_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }

  spec {
    tls {
      hosts = [
        "sonarr.${var.domain_name}",
      ]
      secret_name = "sonarr-${local.dashed_domain_name}"
    }

    backend {
      service_name = "sonarr-service"
      service_port = 80
    }

    rule {
      host = "sonarr.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "sonarr-service"
            service_port = 80
          }
        }

      }
    }

  }

}

resource "kubernetes_service" "sonarr_service" {
  count = var.sonarr_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name      = "sonarr-service"
  }

  spec {
    type      = "ClusterIP"
    selector  = {
      "app.kubernetes.io/name" = "sonarr"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8989
    }

  }
}

resource "kubernetes_stateful_set" "sonarr" {
  count = var.sonarr_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name      = "sonarr"
    labels = {
      "app.kubernetes.io/name" = "sonarr"
    }
  }

  spec {
    service_name = "sonarr"
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "sonarr"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"          = "sonarr"
          "app.kubernetes.io/allow-access"  = "torrent-client"
          "app.kubernetes.io/part-of"       = "htpc"
        }
      }

      spec {
        container {
          name  = "sonarr"
          image = "hotio/sonarr:phantom"

          env {
            name  = "PUID"
            value = "1000"
          }

          env {
            name  = "PGID"
            value = "1000"
          }

          env {
            name  = "TZ"
            value = var.default_time_zone
          }

          port {
            container_port = 7878
          }

          volume_mount {
            name        = "sonarr-data-volume"
            mount_path  = "/config"
          }

          volume_mount {
            mount_path  = "/mnt/local"
            name        = "nfs-media"
          }

        }

        volume {
          name = "sonarr-data-volume"
          persistent_volume_claim {
            claim_name = "sonarr-data-volume"
          }
        }

        volume {
          name      = "nfs-media"
          nfs {
            path    = "/mnt/local/media"
            server  = var.nfs_server_address
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "sonarr-data-volume"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "7Gi"
          }
        }
      }
    }

  }
}

#############################################################
# Deemix
# Ref: https://gitlab.com/Bockiii/deemix-docker
#############################################################
resource "kubernetes_ingress" "deemix_ingress" {
  count = var.deemix_enabled ? 1 : 0

  metadata {
    name      = "deemix-ingress"
    namespace = local.media_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "deemix.${var.domain_name}",
      ]
      secret_name = "deemix-${local.dashed_domain_name}"
    }

    backend {
      service_name = "deemix-service"
      service_port = 80
    }

    rule {
      host = "deemix.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "deemix-service"
            service_port = 80
          }
        }

      }
    }

  }

}

resource "kubernetes_service" "deemix_service" {
  count = var.deemix_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name = "deemix-service"
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "deemix"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 6595
    }

  }
}

resource "kubernetes_stateful_set" "deemix" {
  count = var.deemix_enabled ? 1 : 0

  metadata {
    namespace = local.media_namespace
    name      = "deemix"
    labels = {
      "app.kubernetes.io/name" = "deemix"
    }
  }

  spec {
    service_name  = "deemix"
    replicas      = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "deemix"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "deemix"
          "app.kubernetes.io/part-of"   = "htpc"
        }
      }

      spec {
        container {
          name = "deemix"
          image = "registry.gitlab.com/bockiii/deemix-docker"
          image_pull_policy = "Always"

          env {
            name = "PUID"
            value = "1000"
          }

          env {
            name = "PGID"
            value = "1000"
          }

          env {
            name = "TZ"
            value = var.default_time_zone
          }

          env {
            name = "ARL"
            value = var.deemix_arl
          }

          port {
            container_port = 7878
          }

          volume_mount {
            name = "deemix-data-volume"
            mount_path = "/config"
          }

          volume_mount {
            mount_path = "/downloads"
            name = "nfs-media-music"
          }

        }

        volume {
          name = "deemix-data-volume"
          persistent_volume_claim {
            claim_name = "deemix-data-volume"
          }
        }

        volume {
          name = "nfs-media-music"
          nfs {
            path = "/mnt/local/media/music"
            server = var.nfs_server_address
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "deemix-data-volume"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "200Mi"
          }
        }
      }
    }

  }
}

#############################################################
# Qbittorrent
# Ref: https://github.com/linuxserver/docker-qbittorrent
#############################################################
resource "kubernetes_ingress" "qbittorrent_ingress" {
  count = var.qbittorrent_enabled ? 1 : 0
  metadata {
    name      = "qbittorrent-ingress"
    namespace = local.media_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/auth-url"        = "https://forwardauth.${var.domain_name}/verify?uri=$scheme://$host$request_uri"
      "nginx.ingress.kubernetes.io/auth-signin"     =  "https://forwardauth.${var.domain_name}?uri=$scheme://$host$request_uri"
    }
  }

  spec {
    tls {
      hosts = [
        "qbittorrent.${var.domain_name}",
      ]
      secret_name = "qbittorrent-${local.dashed_domain_name}"
    }

    backend {
      service_name = "qbittorrent-service"
      service_port = 80
    }

    rule {
      host = "qbittorrent.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "qbittorrent-service"
            service_port = 80
          }
        }

      }
    }

  }

}

resource "kubernetes_service" "qbittorrent_service" {
  count = var.qbittorrent_enabled ? 1 : 0
  metadata {
    namespace = local.media_namespace
    name      = "qbittorrent-service"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "qbittorrent"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

  }
}

resource "kubernetes_stateful_set" "qbittorrent" {
  count = var.qbittorrent_enabled ? 1 : 0
  metadata {
    namespace = local.media_namespace
    name      = "qbittorrent"
    labels = {
      "app.kubernetes.io/name"      = "qbittorrent"
    }
  }

  spec {
    service_name  = "qbittorrent"
    replicas      = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "qbittorrent"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "qbittorrent"
          "app.kubernetes.io/component" = "torrent-client"
          "app.kubernetes.io/part-of"   = "htpc"
        }
      }

      spec {
        # Disable all possible connections
        # VPN container will open required ports and allow
        # required rules and implement full kill switch
        init_container {
          name  = "minimal-kill-switch"
          image = "nicolaka/netshoot"
          security_context {
            privileged = true
            capabilities {
              add = [
                "NET_ADMIN",
                "SYS_MODULE",
              ]
            }
          }
          command = [
            "sh",
            "-c",
            "iptables -F && iptables -X && iptables -P INPUT DROP && iptables -P FORWARD DROP && iptables -P OUTPUT DROP && exit 0",
          ]
        }

        # VPN Container
        # All traffic from torrent client will be routed through this container
        container {
          security_context {
            privileged = true
            capabilities {
              add = [
                "NET_ADMIN",
                "SYS_MODULE",
              ]
            }
          }

          name  = "nordvpn"
          image = "bubuntux/nordvpn"

          env {
            name  = "USER"
            value = var.nordvpn_username
          }

          env {
            name  = "PASS"
            value = var.nordvpn_password
          }

          env {
            name  = "TECHNOLOGY"
            value = "NordLynx"
          }

          env {
            name  = "CONNECT"
            value = length(var.nordvpn_server) > 0 ? var.nordvpn_server : ""
          }

          env {
            name  = "PORTS"
            value = "8080"
          }

          env {
            name = "NETWORK"
            # Allow access from all private networks
            value = "10.0.0.0/8,172.16.0.0/12,192.0.0.0/24,192.168.0.0/16,198.18.0.0/15"
          }

          volume_mount {
            mount_path = "/dev/net/tun"
            name      = "dev-net-tun"
            read_only = true
          }

        }

        container {
          name  = "qbittorrent"
          image = "linuxserver/qbittorrent"

          env {
            name  = "PUID"
            value = "1000"
          }

          env {
            name  = "PGID"
            value = "1000"
          }

          env {
            name  = "TZ"
            value = var.default_time_zone
          }

          env {
            name  = "UMASK_SET"
            value = "022"
          }

          env {
            name  = "WEBUI_PORT"
            value = "8080"
          }


          port {
            name = "web"
            container_port = 8080
          }

          port {
            name            = "qbittorrent-tcp"
            protocol        = "TCP"
            container_port  = 6881
          }

          port {
            name            = "qbittorrent-udp"
            container_port  = 6881
            protocol        = "UDP"
          }

          volume_mount {
            name        = "qbittorrent-data-volume"
            mount_path  = "/config"
          }

          volume_mount {
            mount_path  = "/downloads"
            name        = "nfs-media"
          }

        }

        volume {
          name = "qbittorrent-data-volume"
          persistent_volume_claim {
            claim_name = "qbittorrent-data-volume"
          }
        }

        volume {
          name = "dev-net-tun"
          host_path {
            path = "/dev/net/tun"
          }
        }

        volume {
          name = "nfs-media"
          nfs {
            path    = "/mnt/local/media/"
            server  = var.nfs_server_address
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "qbittorrent-data-volume"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "3Gi"
          }
        }
      }
    }

  }
}

# Network policy that will allow correctly labeled pods to access torrent client
resource "kubernetes_network_policy" "torrent_client_network_policy" {
  metadata {
    name      = "torrent-client-network-policy"
    namespace = local.media_namespace
  }
  spec {
    policy_types = [
      "Ingress",
    ]

    pod_selector {
      match_labels = {
        "app.kubernetes.io/component" = "torrent-client"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
           "app.kubernetes.io/allow-access" = "torrent-client"
          }
        }
      }

      ports {
        protocol = "TCP"
        port = "8080"
      }

    }

  }
}

# Network policy that will allow ingress controller access torrent client's webui
resource "kubernetes_network_policy" "torrent_client_network_policy_ingress_controller" {
  metadata {
    name      = "torrent-client-network-policy-ingress-controller"
    namespace = local.media_namespace
  }
  spec {
    policy_types = [
      "Ingress",
    ]

    pod_selector {
      match_labels = {
        "app.kubernetes.io/component" = "torrent-client"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "app.kubernetes.io/component" = "ingress-controller"
          }
        }

        pod_selector {
          match_expressions {
            key = "app.kubernetes.io/component"
            operator = "In"
            values = [
              "controller",
            ]
          }
        }
      }

      ports {
        protocol = "TCP"
        port = "8080"
      }

    }

  }
}
