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

#############################################################
# Vault
# Ref: https://github.com/hashicorp/vault-helm
#############################################################
//locals {
//  vault_helm_values = {
//    server = {
//      standalone = {
//        enabled = true
//        config = <<EOF
//ui = true
//
//listener "tcp" {
//  tls_disable = 1
//  address = "[::]:8200"
//  cluster_address = "[::]:8201"
//}
//storage "file" {
//  path = "/vault/data"
//}
//EOF
//      }
//
//      service = {
//        enabled = true
//      }
//
//      dataStorage = {
//        enabled = true
//        size = "5Gi"
////        storageClass = null
//        accessMode = "ReadWriteOnce"
//      }
//
//    }
//
//    ui = {
//      enabled = true
////      serviceType = "ClusterIP"
//    }
//  }
//}
//
//
//resource "helm_release" "vault" {
//  count = 1
//  name  = "vault"
//  chart = "vault"
//  repository = "https://helm.releases.hashicorp.com"
//  namespace = local.private_namespace
//
//  values = [
//    yamlencode(local.vault_helm_values)
//  ]
//}
//
//resource "kubernetes_ingress" "vault_ui_ingress" {
//  count = 1
//
//  metadata {
//    namespace = local.private_namespace
//    name = "vault-ui-ingress"
//    annotations = {
//      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
//      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
//      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
//    }
//  }
//  spec {
//    tls {
//      hosts = [
//        "vault.${var.domain_name}",
//      ]
//      secret_name = "vault-${local.dashed_domain_name}"
//    }
//
//    backend {
//      service_name = "vault-ui-service"
//      service_port = 8200
//    }
//
//    rule {
//      host = "vault.${var.domain_name}"
//      http {
//        path {
//          path = "/"
//          backend {
//            service_name = "vault-ui-service"
//            service_port = 8200
//          }
//        }
//
//      }
//    }
//
//  }
//}
