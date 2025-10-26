output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnets of the VPC"
  value       = module.vpc.private_subnets
}

output "cluster_name" {
  description = "Name of the EKS Cluster"
  value       = module.eks.cluster_name
}
output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}