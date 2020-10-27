locals {
  utils_namespace = kubernetes_namespace.utils.metadata[0].name
}

resource "kubernetes_namespace" "utils" {
  metadata {
    name = "utils"
    labels = {
      "app.kubernetes.io/name" = "utils"
    }
  }
}

#############################################################
# Cert-manager - Certificate
# Note: Wildcard certificate issued for utils namespace
# Ref: https://cert-manager.io/docs/concepts/certificate/
#############################################################
resource "helm_release" "cert_manager_wildcard_certificate_utils" {
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0
  namespace = local.utils_namespace

  chart = "${local.helm_charts_path}/cert-manager-resources/certificate"
  name  = "cert-manager-wildcard-certificate-${local.utils_namespace}"

  set {
    name = "name"
    value = "letsencrypt-wildcard-${local.utils_namespace}"
  }

  set {
    name = "namespace"
    value = local.utils_namespace
  }

  set {
    name = "secretName"
    value = "letsencrypt-wildcard-secret-${local.utils_namespace}"
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
# LanguageTool
# Ref:
# - https://github.com/languagetool-org/languagetool
# - https://github.com/silvio/docker-languagetool
#############################################################
resource "kubernetes_ingress" "language_tool_ingress" {
  count = 1
  metadata {
    name = "language-tool-ingress"
    namespace = local.utils_namespace
    annotations = {
      "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/rewrites-target"   = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"      = "true"
    }
  }

  spec {
    tls {
      hosts = [
        "*.${var.domain_name}",
      ]
      secret_name = "letsencrypt-wildcard-secret-${local.utils_namespace}"
    }

    rule {
      host = "languagetool.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "language-tool-service"
            service_port = 80
          }
        }
      }
    }

  }
}

resource "kubernetes_service" "language_tool_service" {
  count = 1
  metadata {
    namespace = local.utils_namespace
    name = "language-tool-service"
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "language-tool"
    }

    port {
      name        = "language-tool-http"
      port        = 80
      target_port = 8010
    }

  }
}

resource "kubernetes_deployment" "language_tool" {
  count = 1

  metadata {
    name = "language-tool"
    namespace = local.utils_namespace

    labels = {
      "app.kubernetes.io/name" = "language-tool"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "language-tool"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "language-tool"
        }
      }
      spec {
        container {
          name              = "language-tool"
          image             = "silviof/docker-languagetool:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port  = 8010
            protocol        = "TCP"
            name            = "http"
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
resource "kubernetes_ingress" "pihole_ingress" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-ingress"
    namespace = local.utils_namespace
    annotations = {
      "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/rewrites-target"   = "/admin"
      "nginx.ingress.kunernetes.io/ssl-redirect"      = "true"
    }
  }

  spec {
    tls {
      hosts = [
        "*.${var.domain_name}",
      ]
      secret_name = "letsencrypt-wildcard-secret-${local.utils_namespace}"
    }

    rule {
      host = "pihole.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "proxy-service"
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
    namespace = local.utils_namespace
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

resource "kubernetes_service" "pihole_service" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-service"
    namespace = local.utils_namespace
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
    namespace = local.utils_namespace
  }

  data = {
    "post_init.sh" = <<EOF
#!/usr/bin/env bash

declare -a adLists_enabled=(
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all-but-whatsapp
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/microsoft/all
https://mirror1.malwaredomains.com/files/justdomains
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/hosts.txt
https://gitlab.com/ookangzheng/dbl-oisd-nl/raw/master/dbl.txt
https://sysctl.org/cameleon/hosts
https://block.energized.pro/ultimate/formats/hosts.txt
)

declare -a adLists_disabled=(
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/localized
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/amazon/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/apple/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/cloudflare/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/mozilla/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/pinterest/all
)

# Set empty password. Authentication will be provided by IDP
echo " " | pihole -a -p
# Clear all Ad lists
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist"

# Add Ad lists and mark them enabled
for i in $${adLists_enabled[@]}; do
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address,enabled) VALUES ('$i', 1)";
done

# Add Ad lists and mark them disabled
for i in $${adLists_disabled[@]}; do
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address,enabled) VALUES ('$i', 0)";
done

# Update blacklists
pihole -g

# Restart DNS Resolver
pihole restartdns

# Restart
service pihole-FTL restart
EOF
  }
}

resource "kubernetes_deployment" "pihole" {
  count = var.pihole_enabled ? 1 : 0

  metadata {
    name = "pihole"
    namespace = local.utils_namespace

    annotations = {
      "configmap.reloader.stakater.com/reload": "pihole-post-init-script"
    }

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

resource "kubernetes_service" "pihole_oauth_proxy_service" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "proxy-service"
    namespace = local.utils_namespace
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "pihole-oauth-proxy"
    }

    port {
      port        = 80
      target_port = 4180
      name        = "http-auth"
    }
  }
}

resource "kubernetes_config_map" "pihole_oauth_proxy_config" {
  count = var.pihole_enabled ? 1 : 0
  metadata {
    name = "pihole-oauth-proxy-config"
    namespace = local.utils_namespace
  }

  data = {
    #############################################################
    # Reference: https://github.com/oauth2-proxy/oauth2-proxy/blob/master/docs/configuration/configuration.md
    #############################################################
    "config.conf" = <<EOF
http_address = "0.0.0.0:4180"
reverse_proxy = "true"

provider = "keycloak"
cookie_name = "oauth2_proxy"
cookie_secret = "La5kIO4XDSHQ6Qx9BAVFFw=="
email_domains = [
  "*"
]
client_id = "pomerium"
client_secret = "7d22a0b0-180b-4d7d-bba3-74ba3f8d1c46"

login_url = "https://keycloak.devset.app/auth/realms/lab/protocol/openid-connect/auth"
redeem_url = "https://keycloak.devset.app/auth/realms/lab/protocol/openid-connect/token"
validate_url = "https://keycloak.devset.app/auth/realms/lab/protocol/openid-connect/userinfo"
keycloak_group = "htpc"
upstreams = [
  "http://pihole-service"
]
pass_authorization_header = true
set_authorization_header = true
ssl_insecure_skip_verify = true
scope = "email profile groups"

session_store_type = "redis"
redis_password = "${var.redis_password}"
redis_connection_url = "redis://redis-master.db.svc.cluster.local:6379/0"

skip_provider_button = true

EOF
  }

}

resource "kubernetes_deployment" "pihole_oauth_proxy" {
  count = var.pihole_enabled ? 1 : 0

  metadata {
    name = "pihole-oauth-proxy"
    namespace = local.utils_namespace

    annotations = {
      "configmap.reloader.stakater.com/reload": "pihole-oauth-proxy-config"
    }

    labels = {
      "app.kubernetes.io/name" = "pihole-oauth-proxy"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "pihole-oauth-proxy"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "pihole-oauth-proxy"
        }
      }

      spec {
        container {
          name              = "pihole-oauth-proxy"
          image             = "quay.io/oauth2-proxy/oauth2-proxy"
          image_pull_policy = "Always"

          args = [
            "--config=/tmp/config.conf"
          ]

          port {
            container_port  = 4180
            protocol        = "TCP"
            name            = "http"
          }

          volume_mount {
            mount_path = "/tmp/config.conf"
            name = "pihole-oauth-proxy-config"
            sub_path = "config.conf"
          }

        }

        volume {
          name = "pihole-oauth-proxy-config"

          config_map {
            name = "pihole-oauth-proxy-config"
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.redis,
  ]

}