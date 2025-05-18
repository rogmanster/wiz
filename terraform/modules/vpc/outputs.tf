output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The created vpc_id"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "The created public subnet ids"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "The created private subnet ids"
}
