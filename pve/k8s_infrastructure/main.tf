locals {
  helm_chart_path = pathexpand("${path.module}/../../modules/helm")
  metallb_namespace       = kubernetes_namespace.metallb_system.metadata[0].name
  cert_manager_namespace  = kubernetes_namespace.cert_manager.metadata[0].name
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
resource "helm_release" "nginx_ingress" {
  name  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
}

#############################################################
# Cert Manager
# Ref: https://github.com/jetstack/cert-manager
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
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0

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
    value = "{${join(",", [ var.cloudflare_zone_name ])}}"
  }

  depends_on = [
    helm_release.cert_manager
  ]

}

# Cloudflare API token
# Used by cert manager for DNS challenges
resource "kubernetes_secret" "cloudflare_key_secret" {
  count = length(var.cloudflare_api_token) > 0 ? 1 : 0

  metadata {
    name = "cloudflare-api-token-secret"
    namespace = local.cert_manager_namespace
  }

  data = {
    api-token = var.cloudflare_api_token
  }

}

#############################################################
# Kubernetes Dashboard
# Ref: https://github.com/kubernetes/dashboard
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

# Proxy K8s dashboard through Pomerium
resource "kubernetes_ingress" "k8s_dashboard_ingress" {
  metadata {
    namespace = "default"
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
            service_name = "pomerium-proxy"
            service_port = 443
          }
        }
      }
    }

  }
}

#############################################################
# Pomerium
# Ref: https://www.pomerium.io/
#############################################################
locals {
  pomerium_config = {
    image = {
      tag = "master"
      pullPolicy = "Always"
    }
    // TODO: Add hosted IDP (Keycloak or Dex)
    authenticate = {
      idp = {
        provider = "github"
        clientID = var.github_oauth_client_id
        clientSecret = var.github_oauth_client_secret
      }
    }

    forwardAuth = {
      enabled = true
    }

    config = {
      rootDomain = var.domain_name
      policy = [
        # K8s Dashboard
        {
          from = "https://k8s-dashboard.${var.domain_name}"
          to = "https://kubernetes-dashboard.kube-system.svc.cluster.local"
          //preserve_host_header = true
          // allow_websockets: true
          // TODO: Remove static list of users, replace it with centralized solution
          allowed_users = [
            var.user_email
          ]
          tls_skip_verify = true
          set_request_headers = {
            Authorization = "Bearer ${var.k8s_dashboard_token}"
          }
        },
        # PiHole
        {
          from = "https://pihole.${var.domain_name}"
          to = "http://pihole-service.default.svc.cluster.local"
          allowed_users = [
            var.user_email
          ]
        },
      ]
    }

    ingress = {
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
        "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }

      secretName = "pomerium-ingress-tls"
    }
  }

}

resource "helm_release" "pomerium" {
  name  = "pomerium"
  chart = "pomerium"
  repository = "https://helm.pomerium.io"

  values = [
    yamlencode(local.pomerium_config)
  ]
}
