module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name                         = local.name
  cluster_endpoint_public_access       = true
  authentication_mode                  = "API"

  access_entries = {
    terraform_admin = {
      principal_arn   = "arn:aws:iam::436648017334:user/tech-challenge-terraform-user"
      access_policies = [
        "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      ]
    }

    github_admin = {
      principal_arn   = "arn:aws:iam::436648017334:user/tech-challenge-github-actions-user"
      access_policies = [
        "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      ]
    }
  }

  create_kms_key             = false
  cluster_encryption_config  = []

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]

    node_security_group_tags = {
      "kubernetes.io/cluster/${local.name}" = null
    }
  }

  eks_managed_node_groups = {
    java-ms-group = {
      min_size       = 2
      max_size       = 6
      desired_size   = 3
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      labels = {
        workload = "java-spring"
      }

      tags = {
        Name = "eks-java-nodegroup"
      }

      security_groups = [aws_security_group.eks_sg.id]
    }
  }
}