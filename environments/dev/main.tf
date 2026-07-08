module "vpc" {
  source = "../../modules/vpc"

  name = var.cluster_name
  # all other vpc variables use their cost-optimized defaults
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
}

module "eks_node_group" {
  source = "../../modules/eks-node-group"

  cluster_name = module.eks_cluster.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
}

module "irsa_example" {
  source = "../../modules/irsa"

  role_name             = "${var.cluster_name}-example-role"
  oidc_provider_arn      = module.eks_cluster.oidc_provider_arn
  oidc_provider_url      = module.eks_cluster.oidc_provider_url
  namespace              = "default"
  service_account_name   = "example-sa"
  policy_arns            = []
}