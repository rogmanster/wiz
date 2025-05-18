resource "kubernetes_deployment" "tasky" {
  metadata {
    name = "tasky"
    labels = {
      app = "tasky"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tasky"
      }
    }

    template {
      metadata {
        labels = {
          app = "tasky"
        }
      }

      spec {
        service_account_name = "tasky-sa"

        container {
          name  = "tasky"
          image = "ghcr.io/rogmanster/wiz-tasky:latest"

          port {
            container_port = 8080
          }

          env {
            name  = "MONGODB_URI"
            value = "mongodb://appuser:app123@${var.mongodb_ip}:27017/go-mongodb"
          }

          env {
            name  = "SECRET_KEY"
            value = "mysecret123"
          }
        }
      }
    }
  }
}

