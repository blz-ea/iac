locals {
  private_namespace = kubernetes_namespace.private.metadata[0].name
}

resource "kubernetes_namespace" "private" {
  metadata {
    name = "private"
    labels = {
      "app.kubernetes.io/name" = "private"
    }
  }
}

#############################################################
# Cert-manager - Certificate
# Note: Wildcard certificate issued for private namespace
# Ref: https://cert-manager.io/docs/concepts/certificate/
#############################################################
resource "helm_release" "cert_manager_wildcard_certificate_private" {
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0
  namespace = local.private_namespace

  chart = "${local.helm_charts_path}/cert-manager-resources/certificate"
  name  = "cert-manager-wildcard-certificate-${local.private_namespace}"

  set {
    name = "name"
    value = "letsencrypt-wildcard-${local.private_namespace}"
  }

  set {
    name = "namespace"
    value = local.private_namespace
  }

  set {
    name = "secretName"
    value = "letsencrypt-wildcard-secret-${local.private_namespace}"
  }

  set {
    name = "dnsNames"
    value = "{${join(",", [ "*.${var.cloudflare_zone_name}" ])}}"
  }

  set {
    name = "issuerRef.name"
    value = local.cert_manager_cluster_issuer_name
  }

  set {
    name = "issuerRef.kind"
    value = "ClusterIssuer"
  }

  depends_on = [
    helm_release.cert_manager_cluster_issuer,
    helm_release.cert_manager,
  ]

}

#############################################################
# Bitwarden RS
# Ref: https://github.com/dani-garcia/bitwarden_rs
#############################################################
resource "kubernetes_ingress" "bitwarden_rs_ingress" {
  count = var.bitwarden_enabled ? 1 : 0

  metadata {
    namespace = local.private_namespace
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
        "*.${var.domain_name}",
      ]
      secret_name = "letsencrypt-wildcard-secret-${local.private_namespace}"
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
  count = var.bitwarden_enabled ? 1 : 0

  metadata {
    namespace = local.private_namespace
    name = "bitwarden-rs-service"
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "bitwarden-rs"
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
  count = var.bitwarden_enabled ? 1 : 0

  metadata {
    namespace = local.private_namespace
    name      = "bitwarden-rs"
    labels = {
      "app.kubernetes.io/name" = "bitwarden-rs"
    }
  }

  spec {
    service_name  = "bitwarden-rs"
    replicas      = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "bitwarden-rs"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "bitwarden-rs"
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

        volume {
          name = "bitwarden-rs-data-volume"
          persistent_volume_claim {
            claim_name = "bitwarden-rs-data-volume"
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
        access_modes = [
          "ReadWriteOnce"
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
