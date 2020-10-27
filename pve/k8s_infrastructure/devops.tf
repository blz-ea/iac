locals {
  devops_namespace = kubernetes_namespace.devops.metadata.0.name
}

resource "kubernetes_namespace" "devops" {
  metadata {
    name = "devops"

    labels = {
      "app.kubernetes.io/name" = "devops"
    }
  }
}

#############################################################
# Cert-manager - Certificate
# Note: Wildcard certificate issued for devops namespace
# Ref: https://cert-manager.io/docs/concepts/certificate/
#############################################################
resource "helm_release" "cert_manager_wildcard_certificate_devops" {
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0
  namespace = local.devops_namespace

  chart = "${local.helm_charts_path}/cert-manager-resources/certificate"
  name  = "cert-manager-wildcard-certificate-${local.devops_namespace}"

  set {
    name = "name"
    value = "letsencrypt-wildcard-${local.devops_namespace}"
  }

  set {
    name = "namespace"
    value = local.devops_namespace
  }

  set {
    name = "secretName"
    value = "letsencrypt-wildcard-secret-${local.devops_namespace}"
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

##############################################################################
# Jenkins
# Ref: https://github.com/jenkinsci/docker/blob/master/README.md
##############################################################################
resource "kubernetes_ingress" "jenkins_ingress" {
  count = 1
  metadata {
    name      = "jenkins-ingress"
    namespace = local.devops_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "true"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "*.${var.domain_name}",
      ]
      secret_name = "letsencrypt-wildcard-secret-${local.devops_namespace}"
    }

    backend {
      service_name = "jenkins-service"
      service_port = 80
    }

    rule {
      host = "jenkins.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "jenkins-service"
            service_port = 80
          }
        }

      }
    }

  }

}

resource "kubernetes_stateful_set" "jenkins" {
  // TODO: Add LDAP Authentication
  count = 1
  metadata {
    namespace = local.devops_namespace
    name = "jenkins"
    labels = {
      "app.kubernetes.io/name" = "jenkins"
    }
  }

  spec {
    service_name = "jenkins"
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "jenkins"
        }
      }

      spec {
        security_context {
          run_as_user = 1000
          run_as_group = 1000
        }
        container {
          name = "jenkins"
          image = "bitnami/jenkins"

          env {
            name = "JENKINS_USERNAME"
            value = "user"
          }

          env {
            name = "JENKINS_PASSWORD"
            value = "xrvtsklo"
          }

          env {
            name = "JENKINS_HOME"
            value = "/var/jenkins_home"
          }

          port {
            container_port = 8080
            name = "http-port"
          }

//          port {
//            container_port = 50000
//            name = "agent-port"
//          }


          volume_mount {
            name = "jenkins-data-volume"
            mount_path = "/var/jenkins_home"
          }

        }

        volume {
          name = "jenkins-data-volume"
          persistent_volume_claim {
            claim_name = "jenkins-data-volume"
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "jenkins-data-volume"
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

  depends_on = [
    kubernetes_storage_class.default_storage_class
  ]

}

resource "kubernetes_service" "jenkins_service" {
  count = 1
  metadata {
    name      = "jenkins-service"
    namespace = local.devops_namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "jenkins"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }

  }

}