region       = "us-east-1"
account_id   = "194722417082"
cluster_name = "eks-cluster"

# Variables passing to vpc
vpc_cidr           = "10.193.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
private_subnets    = ["10.193.1.0/24", "10.193.2.0/24"]
public_subnets     = ["10.193.3.0/24", "10.193.4.0/24"]

public_subnet_names  = ["Cluster-1a-public", "Cluster-1b-public"]
private_subnet_names = ["Cluster-1a-private", "Cluster-1b-private"]

default_tags = {
  Environment = "dev"
  Owner       = "Devops"
}