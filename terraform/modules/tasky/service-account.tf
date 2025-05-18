resource "kubernetes_service_account" "tasky" {
  metadata {
    name      = "tasky-sa"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role_binding" "tasky_admin" {
  metadata {
    name = "tasky-sa-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tasky.metadata[0].name
    namespace = kubernetes_service_account.tasky.metadata[0].namespace
  }
}

