module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # NAT Gateway Configuration
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  cluster_name = var.cluster_name
  common_tags = var.common_tags
}


# ==============================================================================
# EKS Cluster Module
# DISABLED by default to save costs (~$73/month)
# Uncomment the entire module block when ready to deploy
# ==============================================================================

 module "eks_cluster" {
   count  = var.enable_eks ? 1 : 0
   source = "../../modules/eks-cluster"

   cluster_name    = var.cluster_name
   cluster_version = var.cluster_version
   vpc_id          = module.vpc.vpc_id

   # Use both public and private subnets
   subnet_ids = concat(
  module.vpc.public_subnet_ids,
  module.vpc.private_subnet_ids
  )


   # API endpoint configuration
   endpoint_private_access = true
   endpoint_public_access  = true

   common_tags = var.common_tags
 }

 module "eks_nodes" {
  count  = var.enable_eks ? 1 : 0
  source = "../../modules/eks-nodes"

  cluster_name = module.eks_cluster[0].cluster_id
  subnet_ids   = module.vpc.private_subnet_ids

  system_instance_types = var.system_instance_types
  system_desired_size   = var.system_desired_size
  system_min_size       = var.system_min_size
  system_max_size       = var.system_max_size

  common_tags = var.common_tags

  depends_on = [
    module.vpc,            # ensures NAT + routes exist
    module.eks_cluster     # ensures control plane exists
  ]
}


module "karpenter" {
  count  = var.enable_eks ? 1 : 0
  source = "../../modules/karpenter"

  cluster_name     = var.cluster_name
  cluster_endpoint = module.eks_cluster[0].cluster_endpoint
  oidc_provider_arn = module.eks_cluster[0].oidc_provider_arn
  oidc_provider_url = module.eks_cluster[0].oidc_provider_url
  node_role_arn    = module.eks_nodes[0].node_role_arn

  common_tags = var.common_tags

  depends_on = [
    module.eks_cluster,
    module.eks_nodes
  ]
}

