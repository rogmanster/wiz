output "update_kubeconfig" {
  description = "The aws cli command to fetch the kubeconfig for authentication"
  value       = <<EOF
 aws eks update-kubeconfig --region ${var.region} --name ${var.name}-eks-cluster
EOF
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_name" {
  value       = module.eks.cluster_name
}

output "mongodb_backup_service_account_name" {
  value       = kubernetes_service_account.mongodb_backup.metadata[0].name
}

