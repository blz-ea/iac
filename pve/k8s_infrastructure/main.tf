locals {
  helm_chart_path = pathexpand("${path.module}/../../modules/helm")
  metallb_namespace       = kubernetes_namespace.metallb_system.metadata[0].name
  cert_manager_namespace  = kubernetes_namespace.cert_manager.metadata[0].name
}

#############################################################
# MetalLB
#############################################################
resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"

    labels = {
      app = "metallb"
    }
  }
}

resource "kubernetes_config_map" "metallb_config" {
  metadata {
    namespace = local.metallb_namespace
    name = "config"
  }

  data = {
    config = <<EOF
address-pools:
- name: default
  protocol: layer2
  addresses:
  - ${var.metallb_ip_range}
EOF
  }

}

resource "helm_release" "metallb" {
  chart = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  name = "metallb"
  namespace = local.metallb_namespace

  set {
    name = "existingConfigMap"
    value = kubernetes_config_map.metallb_config.metadata[0].name
  }
}

#############################################################
# Nginx Ingress
#############################################################
resource "helm_release" "nginx_ingress" {
  name  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
}

#############################################################
# Cert Manager
#############################################################
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      app = "cert-manager"
    }
  }
}

resource "helm_release" "cert_manager" {
  name  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  namespace = local.cert_manager_namespace

  set {
    name = "installCRDs"
    value = "true"
  }

  set {
    name = "extraArgs"
    value = "{--dns01-recursive-nameservers=1.1.1.1:53\\,8.8.8.8:53}"
  }
}

// Cluster issuer resource
resource "helm_release" "cert_manager_cluster_issuer" {
  chart = "${local.helm_chart_path}/cert-manager-cluster-issuer"
  name = "cert-manager-cluster-issuer"

  set {
    name = "name"
    value = "letsencrypt-prod"
  }

  set {
    name = "email"
    value = var.cloudflare_account_email
  }

  set {
    name = "apiKeySecretRef.enabled"
    value = "true"
  }

  set {
    name = "apiKeySecretRef.name"
    value = "cloudflare-api-key-secret"
  }

  set {
    name = "apiKeySecretRef.key"
    value = "api-key"
  }

  set {
    name = "dnsZones"
    value = "{${join(",", [ var.domain_name ])}}"
  }

}

resource "kubernetes_secret" "cloudflare_key_secret" {
  metadata {
    name = "cloudflare-api-key-secret"
    namespace = local.cert_manager_namespace
  }

  data = {
    api-key = var.cloudflare_api_token
  }

}

#############################################################
# Kubernetes Dashboard
#############################################################
// Dashboard is installed by kubespray

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
