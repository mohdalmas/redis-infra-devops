# Define a map for clusters with associated subnets
locals {
  eks_clusters = {
    cluster_1a = {
      cluster_name      = "${var.cluster_name}-1a"
      private_subnet    = aws_subnet.private_subnets[0].id # Subnet in us-east-1a
      public_subnet     = aws_subnet.public_subnets[1].id  # Public subnet in 1b
      availability_zone = "us-east-1a"
    }
    cluster_1b = {
      cluster_name      = "${var.cluster_name}-1b"
      private_subnet    = aws_subnet.private_subnets[1].id # Subnet in us-east-1b
      public_subnet     = aws_subnet.public_subnets[0].id  # Public subnet in 1a
      availability_zone = "us-east-1b"
    }
  }
}

resource "null_resource" "coredns_run_script" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/coredns_change.sh -c eks-cluster-1a -d eks-cluster-1b -f ${path.module}/files/coredns-configmap-eks-cluster.yaml"
    on_failure = continue
  }

  depends_on     = [aws_eks_cluster.eks_clusters]
}
