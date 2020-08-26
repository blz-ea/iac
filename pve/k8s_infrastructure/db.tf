locals {
  db_namespace = kubernetes_namespace.db.metadata.0.name
}

resource "kubernetes_namespace" "db" {
  metadata {
    name = "db"

    labels = {
      "app.kubernetes.io/name" = "db"
    }
  }
}

################################################################
# MongoDB
# Ref: https://github.com/helm/charts/tree/master/stable/mongodb
################################################################
locals {
  mongodb_helm_values = {
    useStatefulSet      = true
    usePassword         = length(var.mongodb_root_password) > 0 ? true : false
    mongodbRootPassword = var.mongodb_root_password
    persistence = {
      storageClass = false
    }
    service = {
      name = "mongodb-service"
      type = "ClusterIP"
    }

    podLabels = {
      "app.kubernetes.io/name"      = "mongodb"
    }
  }
}

resource "helm_release" "mongodb" {
  count = var.mongodb_enabled ? 1 : 0
  // TODO: Collect metrics
  // TODO: Add LDAP Authentication
  name  = "mongodb"
  chart = "stable/mongodb"
  namespace = local.db_namespace

  values = [
    yamlencode(local.mongodb_helm_values)
  ]
}

resource "kubernetes_service" "mongodb_lb_service" {
  count = var.mongodb_enabled ? 1 : 0
  metadata {
    name = "mongodb-lb-service"
    namespace = local.db_namespace
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/name" = "mongodb"
    }

    port {
      port        = 27017
      target_port = 27017
      protocol    = "TCP"
      name        = "mongodb"
    }

  }

}

################################################################
# Redis
# Ref: https://github.com/helm/charts/blob/master/stable/redis/
################################################################
locals {
  redis_helm_values = {
    global = {
      redis = {
        password = var.redis_password
      }
    }
    usePassword = length(var.redis_password) > 0 ? true : false
    cluster = {
      enabled = false
      slaveCount = 1
    }

    master = {
      podLabels = {
        "app.kubernetes.io/name" = "redis"
      }
    }
  }

}

resource "helm_release" "redis" {
  // TODO: Collect metrics
  count = var.redis_enabled ? 1 : 0
  name  = "redis"
  chart = "stable/redis"
  namespace = local.db_namespace

  values = [
    yamlencode(local.redis_helm_values)
  ]
}

resource "kubernetes_service" "redis_lb_service" {
  count = var.redis_enabled ? 1 : 0
  metadata {
    name = "redis-lb-service"
    namespace = local.db_namespace
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/name" = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
      name        = "redis"
    }

  }

}

################################################################
# PostgreSQL
# Ref: https://hub.helm.sh/charts/bitnami/postgresql-ha
################################################################
locals {
  postgresql_helm_values = {
    global = {
      postgresql = {
        postgresqlPassword = var.postgresql_password
      }
    }

    replication = {
      slaveReplicas = 0
    }

    podLabels = {
      "app.kubernetes.io/name" = "postgresql"
    }

    persistence = {
//      storageClass = "fast-rbd"
      size = "20Gi"
    }
  }

}

resource "helm_release" "postgresql" {
  count = var.postgresql_enabled ? 1 : 0
  // TODO: Collect metrics
  // TODO: Add LDAP Authentication
  name        = "postgresql"
  repository  = "https://charts.bitnami.com/bitnami"
  chart       = "postgresql"
  namespace   = local.db_namespace

  values = [
    yamlencode(local.postgresql_helm_values)
  ]
}

##############################################################################
# pgAdmin
# Ref: https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
##############################################################################
resource "kubernetes_ingress" "pgadmin_ingress" {
  count = var.pgadmin_enabled ? 1 : 0
  metadata {
    name      = "pgadmin-ingress"
    namespace = local.db_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "pgadmin.${var.domain_name}",
      ]
      secret_name = "pgadmin-${local.dashed_domain_name}"
    }

    backend {
      service_name = "pgadmin-service"
      service_port = 80
    }

    rule {
      host = "pgadmin.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "pgadmin-service"
            service_port = 80
          }
        }

      }
    }

  }

}

resource "kubernetes_stateful_set" "pgadmin" {
  // TODO: Add LDAP Authentication
  count = var.pgadmin_enabled ? 1 : 0
  metadata {
    namespace = local.db_namespace
    name = "pgadmin"
    labels = {
      "app.kubernetes.io/name" = "pgadmin"
    }
  }

  spec {
    service_name = "pgadmin"
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "pgadmin"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "pgadmin"
        }
      }

      spec {
        security_context {
          run_as_user = 5050
          run_as_group = 5050
        }

        container {
          name = "pgadmin"
          image = "dpage/pgadmin4"

          env {
            name = "PGADMIN_DEFAULT_EMAIL"
            value = var.pgadmin_default_email
          }

          env {
            name = "PGADMIN_DEFAULT_PASSWORD"
            value = var.pgadmin_default_password
          }

          port {
            container_port = 80
          }

          volume_mount {
            name = "pgadmin-data-volume"
            mount_path = "/var/lib/pgadmin"
          }

        }

        volume {
          name = "pgadmin-data-volume"
          persistent_volume_claim {
            claim_name = "pgadmin-data-volume"
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "pgadmin-data-volume"
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

resource "kubernetes_service" "pgadmin_service" {
  count = var.pgadmin_enabled ? 1 : 0
  metadata {
    name      = "pgadmin-service"
    namespace = local.db_namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "pgadmin"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

  }

}

################################################################
# ElasticSearch
# Ref: https://www.docker.elastic.co/r/elasticsearch
################################################################
resource "kubernetes_stateful_set" "elasticsearch" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    namespace = local.db_namespace
    name = "elasticsearch"
    labels = {
      "app.kubernetes.io/name" = "elasticsearch"
    }
  }

  spec {
    service_name = "elasticsearch"
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "elasticsearch"
        }
      }

      spec {
        security_context {
          run_as_user = 1000
          run_as_group = 1000
        }

        container {
          name = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch-oss:7.9.0"

          env {
            name = "discovery.type"
            value = "single-node"
          }

          env {
            name = "discovery.zen.minimum_master_nodes"
            value = "1"
          }

          env {
            name = "http.cors.enabled"
            value = "true"
          }

          env {
            name = "http.cors.allow-origin"
            value = "*"
          }

          env {
            name = "http.cors.allow-headers"
            value = "X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization"
          }

          env {
            name = "http.cors.allow-credentials"
            value = "true"
          }

          port {
            container_port = 9200
          }

          port {
            container_port = 9300
          }

          volume_mount {
            name = "elasticsearch-data-volume"
            mount_path = "/usr/share/elasticsearch/data"
          }

        }

        volume {
          name = "elasticsearch-data-volume"
          persistent_volume_claim {
            claim_name = "elasticsearch-data-volume"
          }
        }

      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "elasticsearch-data-volume"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "20Gi"
          }
        }
      }
    }

  }
}

resource "kubernetes_service" "elasticsearch_service" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    name = "elasticsearch-service"
    namespace = local.db_namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "elasticsearch"
    }

    port {
      port        = 80
      target_port = 9200
      protocol    = "TCP"
      name        = "clients"
    }

    port {
      port        = 9300
      target_port = 9300
      protocol    = "TCP"
      name        = "nodes"
    }

  }

}

resource "kubernetes_ingress" "elasticsearch_ingress" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    name = "elasticsearch-ingress"
    namespace = local.db_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "elasticsearch.${var.domain_name}",
      ]
      secret_name = "elasticsearch-${local.dashed_domain_name}"
    }

    backend {
      service_name = "elasticsearch-service"
      service_port = 80
    }

    rule {
      host = "elasticsearch.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "elasticsearch-service"
            service_port = 80
          }
        }

      }
    }

  }

}

################################################################
# ElasticSearch-UI
# Ref: https://github.com/cars10/elasticvue
################################################################
resource "kubernetes_deployment" "elasticsearch_web_ui" {
  count = var.elasticsearch_enabled ? 1 : 0

  metadata {
    name = "elasticsearch-ui"
    namespace = local.db_namespace
    labels = {
      "app.kubernetes.io/name" = "elasticsearch-ui"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "elasticsearch-ui"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "elasticsearch-ui"
        }
      }
      spec {
        container {
          name = "dejavu"
          image = "cars10/elasticvue"

          port {
            container_port = 8080
            protocol = "TCP"
            name = "http"
          }
        }

      }

    }
  }

}

resource "kubernetes_service" "elasticsearch_web_ui_service" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    name = "elasticsearch-ui-service"
    namespace = local.db_namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "elasticsearch-ui"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }

  }

}

resource "kubernetes_ingress" "elasticsearch_web_ui_ingress" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    name      = "elasticsearch-ui-ingress"
    namespace = local.db_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "elasticsearch-ui.${var.domain_name}",
      ]
      secret_name = "elasticsearch-ui-${local.dashed_domain_name}"
    }

    backend {
      service_name = "elasticsearch-ui-service"
      service_port = 80
    }

    rule {
      host = "elasticsearch-ui.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "elasticsearch-ui-service"
            service_port = 80
          }
        }

      }
    }

  }

}
