resource "aws_security_group" "eks_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS Clusters"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# # Add an inbound rule to allow all traffic to each EKS cluster's security group
# resource "aws_security_group_rule" "allow_all_inbound" {
#   for_each = { for cluster in aws_eks_cluster.eks_clusters : cluster.id => cluster.vpc_config[0].cluster_security_group_id }

#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"  # Allow all protocols
#   security_group_id = each.value
#   cidr_blocks       = ["0.0.0.0/0"]

#   depends_on     = [aws_eks_cluster.eks_clusters]
# }


# Security group rule for EKS Cluster 1a
resource "aws_security_group_rule" "allow_all_inbound_cluster_1a" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # Allow all protocols
  security_group_id = aws_eks_cluster.eks_clusters["cluster_1a"].vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [aws_eks_cluster.eks_clusters["cluster_1a"]]
}

# Security group rule for EKS Cluster 1b
resource "aws_security_group_rule" "allow_all_inbound_cluster_1b" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # Allow all protocols
  security_group_id = aws_eks_cluster.eks_clusters["cluster_1b"].vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [aws_eks_cluster.eks_clusters["cluster_1b"]]
}


