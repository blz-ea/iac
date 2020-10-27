locals {
  helm_charts_path        = pathexpand("${path.module}/../../modules/helm")
  dashed_domain_name      = replace(var.domain_name, ".", "-")
  metallb_namespace       = kubernetes_namespace.metallb_system.metadata.0.name
  cert_manager_namespace  = kubernetes_namespace.cert_manager.metadata.0.name
  ingress_nginx_namespace = kubernetes_namespace.ingress_nginx.metadata.0.name

  cert_manager_cluster_issuer_name = "letsencrypt-prod"
}

#############################################################
# MetalLB
# Ref: https://github.com/metallb/metallb
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
# Ref: https://github.com/kubernetes/ingress-nginx
#############################################################
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/name"      = "ingress-nginx"
      "app.kubernetes.io/component" = "ingress-controller"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  namespace   = local.ingress_nginx_namespace
}

#############################################################
# Cert Manager
# Ref: https://github.com/jetstack/cert-manager
#############################################################
locals {
  cert_manager_helm_values = {
    installCRDs = true,
    podLabels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
    extraArgs = [
      "--dns01-recursive-nameservers=1.1.1.1:53\\,8.8.8.8:53"
    ]
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  namespace   = local.cert_manager_namespace

  values = [
    yamlencode(local.cert_manager_helm_values)
  ]
}

# Cloudflare API token
# Used by cert manager for DNS challenges
resource "kubernetes_secret" "cloudflare_key_secret" {
  count = length(var.cloudflare_api_token) > 0 ? 1 : 0

  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = local.cert_manager_namespace
  }

  data = {
    api-token = var.cloudflare_api_token
  }

}

# Cluster issuer resource
resource "helm_release" "cert_manager_cluster_issuer" {
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0

  chart = "${local.helm_charts_path}/cert-manager-resources/cluster-issuer"
  name = "cert-manager-cluster-issuer"

  set {
    name = "name"
    value = local.cert_manager_cluster_issuer_name
  }

  set {
    name = "email"
    value = var.cloudflare_account_email
  }

  set {
    name = "apiTokenSecretRef.enabled"
    value = "true"
  }

  set {
    name = "apiTokenSecretRef.name"
    value = "cloudflare-api-token-secret"
  }

  set {
    name = "apiTokenSecretRef.key"
    value = "api-token"
  }

  set {
    name = "dnsZones"
    value = "{${join(",", [ var.cloudflare_zone_name, "*.${var.cloudflare_zone_name}" ])}}"
  }

  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_key_secret,
  ]

}

#############################################################
# Reloader operator
# Ref: https://github.com/stakater/Reloader
#############################################################
resource "helm_release" "reloader" {
  chart = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  name = "reloader"
}