provider "aws" {
  region = var.region

  # Credentials can be provided by using the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, 
  #and optionally AWS_SESSION_TOKEN environment variables. 
  #The Region can be set using the AWS_REGION or AWS_DEFAULT_REGION environment variables.

}

# Kubernetes Provider Configs for each cluster
provider "kubernetes" {
  alias                  = "cluster_1a"
  host                   = data.aws_eks_cluster.eks["cluster_1a"].endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks["cluster_1a"].certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks["cluster_1a"].name]
    command     = "aws"
  }
}

provider "kubernetes" {
  alias                  = "cluster_1b"
  host                   = data.aws_eks_cluster.eks["cluster_1b"].endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks["cluster_1b"].certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_clusters["cluster_1b"].id]
    command     = "aws"
  }
}


provider "local" {
  # Local provider configuration (if needed)
}