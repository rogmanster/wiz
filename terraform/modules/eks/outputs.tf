output "update_kubeconfig" {
  description = "The aws cli command to fetch the kubeconfig for authentication"
  value = <<EOT

 aws eks update-kubeconfig --region ${var.region} --name ${var.name}-eks-cluster

EOT
}

output "cluster_endpoint" {
  description = "The eks cluster endpoint to be used for the Terraform Kubernetes Provider"
  value = module.eks.cluster_endpoint
  sensitive = true
}

output "cluster_certificate_authority_data" {
  description = "The eks certificate to be used for the Terraform Kubernetes Provider"
  value = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "cluster_name" {
  description = "The eks cluster name"
  value = module.eks.cluster_name
}

output "mongodb_backup_service_account_name" {
  value = kubernetes_service_account.mongodb_backup.metadata[0].name
  description = "The name of the service account used for MongoDB backups"
}

