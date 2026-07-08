output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "node_group_status" {
  value = module.eks_node_group.node_group_status
}

output "oidc_provider_arn" {
  value = module.eks_cluster.oidc_provider_arn
}