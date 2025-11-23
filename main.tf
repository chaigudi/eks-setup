module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = var.namespace
  name      = var.name
  stage     = var.stage

  tags = {
    "project" = var.project
  }
}

locals {
  tags = {
    "kubernetes.io/cluster/${module.label.id}" = "shared"
  }

  public_subnets_additional_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnets_additional_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "3.2.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  tags    = local.tags
  context = module.label.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  public_subnets_additional_tags  = local.public_subnets_additional_tags
  private_subnets_additional_tags = local.private_subnets_additional_tags

  tags    = local.tags
  context = module.label.context
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "4.8.0"

  subnet_ids            = concat(module.subnets.private_subnet_ids, module.subnets.public_subnet_ids)
  kubernetes_version    = var.kubernetes_version
  oidc_provider_enabled = true

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.allowed_cidrs

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  cluster_log_retention_period = var.cluster_log_retention_period

  access_config = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  addons = [
    {
      addon_name                  = "vpc-cni"
      addon_version               = null
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "kube-proxy"
      addon_version               = null
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "coredns"
      addon_version               = null
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    }
  ]

  cluster_depends_on = [module.subnets]

  context = module.label.context
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "3.0.0"

  instance_types = [var.instance_type]
  subnet_ids     = module.subnets.private_subnet_ids

  min_size     = var.min_size
  max_size     = var.max_size
  desired_size = var.desired_size

  capacity_type     = "ON_DEMAND"
  health_check_type = var.health_check_type
  cluster_name      = module.eks_cluster.eks_cluster_id

  block_device_map = {
    "/dev/xvda" = {
      ebs = {
        volume_type           = "gp3"
        volume_size           = 20
        delete_on_termination = true
      }
    }
  }

  node_repair_enabled = true

  context = module.label.context
}
