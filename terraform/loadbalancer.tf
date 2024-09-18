# Attaching LB target to existing LoadBalancer
data "aws_lb_target_group" "redis_target_groups" {
  tags = {
    "kubernetes.io/service-name" = "redis-cluster/redis-cluster-a"
  }
  depends_on = [null_resource.coredns_run_script,null_resource.redis_helm_cluster_run_script]
}

data "aws_instances" "cluster_instances" {
  filter {
    name   = "tag:kubernetes.io/cluster/eks-cluster-1b"
    values = ["owned"]
  }
  depends_on = [data.aws_lb_target_group.redis_target_groups]
}

resource "aws_lb_target_group_attachment" "redis_target_group_attachment" {
  for_each = toset(data.aws_instances.cluster_instances.ids) # Loop through instance IDs
  target_group_arn = data.aws_lb_target_group.redis_target_groups.arn
  target_id        = each.value
  port             = 30079
  depends_on = [data.aws_instances.cluster_instances]
}
