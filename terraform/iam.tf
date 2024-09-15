# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "Eks-Cluster-Role1"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = var.default_tags
}

# Attach multiple policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_eks" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_ec2" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_vpc" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# IAM Role for EKS Nodegroup
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "Eks-Nodegroup-Role1"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = var.default_tags
}

# Attach multiple policies to EKS Nodegroup Role
resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_ec2_container_registry" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_ec2_full_access" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_cni" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_worker" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


#### For External DNS Component ####

resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNSUpdatesPolicy-tf"
  description = "Policy to allow ExternalDNS to manage Route 53 records"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${aws_route53_zone.devops.zone_id}"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })
}


module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "external-dns-role-tf"

  role_policy_arns = {
    policy = aws_iam_policy.external_dns_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = aws_iam_openid_connect_provider.oidc["cluster_1a"].arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
    two = {
      provider_arn               = aws_iam_openid_connect_provider.oidc["cluster_1b"].arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
  tags = var.default_tags
  depends_on=[aws_eks_cluster.eks_clusters]
}


###################################