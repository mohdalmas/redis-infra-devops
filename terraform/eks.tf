
# EKS Clusters #
resource "aws_eks_cluster" "eks_clusters" {
  for_each = local.eks_clusters

  name     = each.value.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  vpc_config {
    subnet_ids         = [each.value.private_subnet, each.value.public_subnet] # Using private subnets
    security_group_ids = [aws_security_group.eks_sg.id]

  }

  tags = var.default_tags
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_eks_access_entry" "eks_access_entry" {
  for_each      = local.eks_clusters
  cluster_name  = aws_eks_cluster.eks_clusters[each.key].name
  principal_arn = "arn:aws:iam::194722417082:root" # Adding route user Access
  type          = "STANDARD"

}
resource "aws_eks_access_policy_association" "eks_access_entry_policy_association" {
  for_each      = local.eks_clusters
  cluster_name  = aws_eks_cluster.eks_clusters[each.key].name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::194722417082:root"
  access_scope {
    type = "cluster"

  }

}

### OIDC config
resource "aws_iam_openid_connect_provider" "oidc" {
  for_each = local.eks_clusters

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc[each.key].certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.oidc[each.key].url
  depends_on      = [aws_eks_cluster.eks_clusters]
}

# AWS EBS CSI Driver
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  for_each = local.eks_clusters

  cluster_name                = each.value.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [aws_eks_addon.coredns]

  # timeouts {
  #   create = "20m"
  #   update = "20m"
  # }
  lifecycle {
    ignore_changes = all
  }
  
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  for_each = local.eks_clusters

  cluster_name                = each.value.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "PRESERVE"
 

  # timeouts {
  #   create = "20m"
  #   update = "20m"
  # }
  lifecycle {
    ignore_changes = all
  }
  depends_on = [aws_eks_addon.kube_proxy]

}

# Kube Proxy
resource "aws_eks_addon" "kube_proxy" {
  for_each = local.eks_clusters

  cluster_name                = each.value.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "PRESERVE"


  # timeouts {
  #   create = "15m"
  #   update = "15m"
  # }
  lifecycle {
    ignore_changes = all
  }
  depends_on = [aws_eks_addon.vpc_cni]
}

# VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  for_each = local.eks_clusters

  cluster_name                = each.value.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "PRESERVE"
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })
  # timeouts {
  #   create = "m"
  #   update = "15m"
  # }
  lifecycle {
    ignore_changes = all
  }
  depends_on = [aws_eks_node_group.node_groups]
}

# EKS Node Groups
resource "aws_eks_node_group" "node_groups" {
  for_each = local.eks_clusters

  cluster_name    = aws_eks_cluster.eks_clusters[each.key].name
  node_group_name = "ng-${each.key}"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = [each.value.private_subnet]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  instance_types = ["t3.medium"]
  tags           = var.default_tags
  depends_on     = [aws_eks_cluster.eks_clusters]
}

