#############################################################
# Kubernetes Dashboard
# Ref: https://github.com/kubernetes/dashboard
#############################################################
// Note: Dashboard is installed by kubespray
// By default kubernetes-dashboard cluster role binding does not have access to cluster resources
// At the moment there is no way to mutate existing resources
// We delete existing binding a create new one with desired permissions
resource "null_resource" "kubernetes_dashboard_remove_role_binding" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.k8s_config_file_path
    }
    command     = "kubectl delete clusterrolebindings.rbac.authorization.k8s.io kubernetes-dashboard"
    on_failure  = continue
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }

  depends_on = [
    null_resource.kubernetes_dashboard_remove_role_binding
  ]

}

resource "kubernetes_ingress" "k8s_dashboard_ingress" {
  metadata {
    namespace = "kube-system"
    name      = "k8s-dashboard-forwardauth"

    annotations = {
      "kubernetes.io/ingress.class"                   = "nginx"
      "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/backend-protocol"  = "HTTPS"

    }
  }
  spec {
    tls {
      hosts = [
        "k8s-dashboard.${var.domain_name}"
      ]
      secret_name = "k8s-dashboard-${replace(var.domain_name, ".", "-")}"
    }

    rule {
      host = "k8s-dashboard.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "kubernetes-dashboard"
            service_port = 443
          }
        }
      }
    }

  }
}