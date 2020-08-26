locals {
  storage_namespace     = kubernetes_namespace.storage.metadata[0].name
}

resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
    labels = {
      "app.kubernetes.io/name"      = "storage"
    }
  }
}
#############################################################
# NFS Cluster
#############################################################
resource "kubernetes_endpoints" "nfs_cluster" {

  metadata {
    name = "nfs-cluster"
    namespace = local.storage_namespace
  }

  subset {
    address {
      ip = var.nfs_server_address
    }

    port {
      port = 2049
      name = "nfs"
      protocol = "TCP"
    }

    port {
      port = 2049
      name = "nfs"
      protocol = "UDP"
    }

  }
}

resource "kubernetes_service" "nfs_cluster" {
  metadata {
    name = "nfs-cluster"
    namespace = local.storage_namespace
  }

  spec {
    cluster_ip = "None"
    port {
      port = 2049
    }
  }
}

#############################################################
# Ceph - RBD provisioner
# Ref: https://quay.io/repository/external_storage/rbd-provisioner?tab=settings
#############################################################
# To get the key: > ceph auth get-key client.admin
resource "kubernetes_secret" "ceph_admin_secret" {
  metadata {
    name = "ceph-secret"
    namespace = "kube-system"
  }
  type = "kubernetes.io/rbd"
  data = {
    key = var.ceph_admin_secret
  }
}

# To create a user account: > ceph --cluster ceph auth get-or-create client.kube mon 'allow r' osd 'allow rwx pool=<pool_name>>'
# To get user account key: > ceph --cluster ceph auth get-key client.kube
resource "kubernetes_secret" "ceph_user_secret" {
  metadata {
    name = "ceph-secret-kube"
    namespace = "kube-system"
  }
  type = "kubernetes.io/rbd"
  data = {
    key = var.ceph_user_secret
  }
}

resource "kubernetes_service_account" "rbd_provisioner_service_account" {
  metadata {
    name = "rbd-provisioner"
    namespace = local.storage_namespace
  }
}

resource "kubernetes_cluster_role" "rbd_provisioner_cluster_role" {
  metadata {
    name = "rbd-provisioner"
  }

  rule {
    api_groups = [""]
    resources = ["persistentvolumes"]
    verbs = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims"]
    verbs = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["storageclasses"]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources = ["services"]
    resource_names = ["kube-dns","coredns"]
    verbs = ["list", "get"]
  }

  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get", "list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    verbs = ["get"]
    resources = ["secrets"]
  }

}

resource "kubernetes_cluster_role_binding" "rbd_provisioner_cluster_binding" {
  metadata {
    name = "rbd-provisioner"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "rbd-provisioner"
  }

  subject {
    kind = "ServiceAccount"
    name = "rbd-provisioner"
    namespace = local.storage_namespace
  }
}

resource "kubernetes_role" "rbd_provisioner_role" {
  metadata {
    name = "rbd-provisioner"
    namespace = local.storage_namespace
  }

  rule {
    api_groups = [""]
    resources = ["secrets"]
    verbs = ["get"]
  }

  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get", "list", "watch", "create", "update", "patch"]
  }

}

resource "kubernetes_role_binding" "rbd_provisioner_role_binding" {
  metadata {
    name = "rbd-provisioner"
    namespace = local.storage_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rbd-provisioner"
  }
  subject {
    kind = "ServiceAccount"
    name = "rbd-provisioner"
    namespace = local.storage_namespace
  }
}

resource "kubernetes_deployment" "rbd_provisioner_deployment" {
  metadata {
    name      = "rbd-provisioner"
    namespace = local.storage_namespace
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "rbd-provisioner"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "rbd-provisioner"
        }
      }
      spec {
        service_account_name = "rbd-provisioner"
        automount_service_account_token = true
        container {
          name = "rbd-provisioner"
          image = "quay.io/external_storage/rbd-provisioner:latest"
          env {
            name = "PROVISIONER_NAME"
            value = "ceph.com/rbd"
          }
        }
      }
    }
  }
}

resource "kubernetes_storage_class" "default_storage_class" {
  count = 1
  storage_provisioner = "ceph.com/rbd"

  metadata {
    name = "fast-rbd"
    annotations = {
      "storageclass.kubernetes.io/is-default-class": "true"
    }
  }

  reclaim_policy = "Retain"
  parameters = {
    monitors              = var.ceph_monitors
    pool                  = var.ceph_pool_name

    adminId               = var.ceph_admin_id
    adminSecretName       = kubernetes_secret.ceph_admin_secret.metadata.0.name
    adminSecretNamespace  = "kube-system"

    userId                = var.ceph_user_id
    userSecretName        = kubernetes_secret.ceph_user_secret.metadata.0.name
    userSecretNamespace   = "kube-system"

    imageFormat           = "2"
    imageFeatures         = "layering"
  }

  depends_on = [
    kubernetes_deployment.rbd_provisioner_deployment,
  ]

}
