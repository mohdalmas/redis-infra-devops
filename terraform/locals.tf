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
## This is the resource to run the Local Script.
resource "null_resource" "coredns_run_script" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/external_dns_install.sh -c eks-cluster-1a -d eks-cluster-1b -f ${path.module}/files/coredns-configmap-eks-cluster.yaml -r ${var.region} -z ${aws_route53_zone.devops.zone_id} -n ${aws_route53_zone.devops.name} -a ${module.iam_eks_role.iam_role_arn}"
    on_failure = continue
  }
# triggers = {
#     always_run = "${timestamp()}"  # Use a timestamp or another always-changing value
#   }
  depends_on     = [aws_eks_addon.coredns]
  
}
