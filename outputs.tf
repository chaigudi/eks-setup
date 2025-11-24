output "cluster_name" {
  value = module.eks_cluster.eks_cluster_id
}

output "cluster_endpoint" {
  value = module.eks_cluster.eks_cluster_endpoint
}

output "cluster_ca" {
  value = module.eks_cluster.eks_cluster_certificate_authority_data
}

output "nodegroup_arn" {
  value = module.eks_node_group.eks_node_group_arn
}

output "private_subnets" {
  value = module.subnets.private_subnet_ids
}

output "public_subnets" {
  value = module.subnets.public_subnet_ids
}

output "region" {
  value = var.region
}
