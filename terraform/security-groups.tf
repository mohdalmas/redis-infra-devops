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


# Add an inbound rule to allow all traffic to each EKS cluster's security group
resource "aws_security_group_rule" "allow_all_inbound" {
  for_each = { for sg_id in [for eks in data.aws_eks_cluster.eks : eks.vpc_config[0].cluster_security_group_id] : sg_id => sg_id }

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # Allow all protocols
  security_group_id = each.value
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on     = [aws_eks_cluster.eks_clusters]
}
