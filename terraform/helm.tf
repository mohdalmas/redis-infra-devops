# Helm chart Installation on cluster_1a Eks Cluster for External-DNS
resource "helm_release" "external_dns_helm_1a" {
 
  provider = helm.cluster_1a # Use Helm provider for cluster 1a
  
  name       = "externaldns-release"
  namespace  = "kube-system"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "external-dns"
  upgrade_install = true


  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = var.region # Use a dynamic region if needed
  }

  set {
    name  = "txtOwnerId"
    value = aws_route53_zone.devops.zone_id
  }

  set {
    name  = "domainFilters[0]"
    value = aws_route53_zone.devops.name
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations"
    value = "eks.amazonaws.com/role-arn: ${module.iam_eks_role.iam_role_arn}"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  timeout = 900
  wait    = true

  depends_on=[aws_eks_node_group.node_groups]
}

# Helm chart Installation on cluster_1b Eks Cluster for External-DNS
resource "helm_release" "external_dns_helm_1b" {
 
  provider = helm.cluster_1b # Use Helm provider for cluster 1a
  
  name       = "externaldns-release"
  namespace  = "kube-system"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "external-dns"
  upgrade_install = true


  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = var.region # Use a dynamic region if needed
  }

  set {
    name  = "txtOwnerId"
    value = aws_route53_zone.devops.zone_id
  }

  set {
    name  = "domainFilters[0]"
    value = aws_route53_zone.devops.name
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations"
    value = "eks.amazonaws.com/role-arn: ${module.iam_eks_role.iam_role_arn}"
  
  
  }

  set {
    name  = "policy"
    value = "sync"
  }

  timeout = 900
  wait    = true

  depends_on=[aws_eks_node_group.node_groups]
}

