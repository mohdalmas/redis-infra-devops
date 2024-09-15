# Output for VPC ID
output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

# Outputs
output "eks_cluster_ids" {
  description = "IDs of the EKS clusters"
  value       = { for k, v in aws_eks_cluster.eks_clusters : k => v.id }
}

output "node_group_ids" {
  description = "IDs of the EKS node groups"
  value       = { for k, v in aws_eks_node_group.node_groups : k => v.id }
}

# Output for Private Subnets (in the VPC)
output "private_subnets" {
  description = "Private subnets associated with the VPC"
  value       = [for subnet in aws_subnet.private_subnets : subnet.id]
}

# Output for Public Subnets (in the VPC)
output "public_subnets" {
  description = "Public subnets associated with the VPC"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id]
}

# Output the name and ID of each hosted zone
output "route53_hosted_zones" {
  description = "List of Route 53 hosted zones with their IDs"
  value       = data.aws_route53_zone.devops.zone_id

}

