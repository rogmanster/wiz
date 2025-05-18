resource "kubernetes_service" "tasky" {
  metadata {
    name = "tasky"
  }

  spec {
    selector = {
      app = "tasky"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 8080
    }
  }
}

