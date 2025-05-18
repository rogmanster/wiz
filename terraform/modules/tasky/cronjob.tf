resource "kubernetes_cron_job_v1" "mongodb_backup" {
  metadata {
    name = "mongodb-backup"
  }

  spec {
    schedule = "*/5 * * * *" # Run every 5 mins
    job_template {
      metadata {
        name = "mongodb-backup-job"
      }

      spec {
        template {
          metadata {
            labels = {
              app = "mongodb-backup"
            }
          }

          spec {
            # Use the IAM-linked service account from variable
            service_account_name = var.mongodb_backup_sa

            container {
              name  = "backup"
              image = "ghcr.io/rogmanster/mongodb-backup:latest"

              env {
                name  = "HOME"
                value = "/tmp"
              }

              command = [
                "/bin/bash",
                "-c",
                <<-EOT
                  set -eux
                  mongodump --uri='mongodb://appuser:app123@${var.mongodb_ip}:27017/go-mongodb' --archive | gzip > /tmp/backup.gz
                  TIMESTAMP=$(date +%F_%T)
                  aws s3 cp /tmp/backup.gz s3://${var.bucket_name}/backup-$TIMESTAMP.gz
                EOT
              ]
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

