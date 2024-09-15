data "aws_region" "current" {}
data "tls_certificate" "oidc" {
  for_each = local.eks_clusters
  url      = aws_eks_cluster.eks_clusters[each.key].identity[0].oidc[0].issuer

}

data "aws_route53_zone" "devops" {
  name         = "devops.com"
  private_zone = true
  depends_on = [aws_route53_zone.devops]
}

data "aws_eks_cluster" "eks" {
  for_each = aws_eks_cluster.eks_clusters

  name = each.value.name
  depends_on = [aws_eks_cluster.eks_clusters]
}

data "aws_eks_cluster_auth" "eks" {
  for_each = aws_eks_cluster.eks_clusters

  name = each.value.name
}


