#############################################################
# NFS Cluster - Default Storage Class
# Ref: https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner
#############################################################
resource "helm_release" "nfs_client_provisioner" {
  count = var.nfs_default_storage_class ? 1 : 0

  chart = "stable/nfs-client-provisioner"
  name = "nfs-client-provisioner"

  set {
    name = "nfs.server"
    value = var.nfs_server_address # For some reason does not accept hostname
  }

  set {
    name = "nfs.path"
    value = "/k8s"
  }

  set {
    name = "storageClass.name"
    value = "default"
  }

  set {
    name = "storageClass.reclaimPolicy"
    value = "Retain"
  }

}

#############################################################
# NFS Cluster
#############################################################
resource "kubernetes_endpoints" "nfs_cluster" {
  count = length(var.nfs_server_address) > 0  ? 1 : 0

  metadata {
    name = "nfs-cluster"
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
  count = length(var.nfs_server_address) > 0  ? 1 : 0

  metadata {
    name = "nfs-cluster"
  }

  spec {
    cluster_ip = "None"
    port {
      port = 2049
    }
  }
}

#############################################################
# Gluster Cluster
#############################################################
resource "kubernetes_endpoints" "gluster_cluster" {
  count = length(var.gluster_cluster_endpoints) > 0 ? 1 : 0

  metadata {
    name = "gluster-cluster"
  }

  subset {
    dynamic address {
      for_each = var.gluster_cluster_endpoints
      content {
        ip = address.value
      }
    }

    dynamic port {
      for_each = var.gluster_cluster_endpoints
      content {
        port = 1
        protocol = "TCP"
      }
    }
  }

}

resource "kubernetes_service" "gluster_cluster" {
  count = length(var.gluster_cluster_endpoints) > 0 ? 1 : 0

  metadata {
    name = "gluster-cluster"
  }

  spec {
    cluster_ip = "None"
    port {
      port = 1
    }
  }
}

