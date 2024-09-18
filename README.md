

**Redis Infrastructure DevOps**
This repository provides Terraform and Helm configurations for setting up and managing Redis infrastructure on AWS EKS clusters.

**Architechture Diagram**


**Table of Contents**
- Introduction
- Prerequisites
- Repository Structure
- Setup Instructions
- Usage


**Introduction**
This repository is designed to help you deploy and manage Redis on AWS EKS clusters using Terraform and Helm. It includes configurations for two EKS clusters and Helm charts for Redis deployment. Scripts and GitHub Actions workflows are also provided to facilitate management and deployment tasks.

**Overview**
This repository provides the tools and configurations necessary to deploy a Redis cluster across two EKS clusters. Key features include:

**Cluster Configuration**: Two EKS clusters are created and configured to work together in a high-availability setup.
**Redis Interaction**: You can interact with the Redis cluster by connecting to any Redis pod and using redis-cli.
**Data Persistence**: Redis data is persisted using EBS volumes with the Append-Only File (AOF) mechanism to ensure data durability.

**External DNS***
The Main issue for Cross cluster is connecting these nodes together which I have resolved using VPC plugin & External DNS.
- Added Nodes using FQDN so they wont reply on pods IP since it is very dynamic.
- Network connectivity is being achived using VPC CNI pluging so it allow inter vpc communidation.
- ExternalDNS used to propagate Pods IP with the FQDN into Route53 and then using Route53 to resolve domain specific query.

**Prerequisites**
Before using this repository, ensure you have the following:

- AWS CLI installed and configured
- Terraform installed
- Helm installed
- kubectl installed

**Repository Structure**
charts/
    └── Helm chart configuration files for Redis deployments.

values_a.yaml
    └── Values for deploying Redis on EKS Cluster 1a.

values_b.yaml
    └── Values for deploying Redis on EKS Cluster 1b.

terraform/
    ├── Contains All Terraform code for creating AWS Infra

scripts/
    └── external_dns_install.sh
        └── Script for updating CoreDNS configurations and INstalling External DNS to update Route53 records automatically.


**bash code**
git clone https://github.com/mohdalmas/redis-infra-devops.git
cd redis-infra-devops

**Setup Terraform**

**Initialize Terraform and apply the configurations to set up the infrastructure:**
terraform init
terraform apply

**Deploy Redis Using Helm:**
Update the Helm chart values for your specific clusters and install Redis:

**For Cluster 1a**
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-1a
helm install redis-cluster-a ./charts -f ./charts/values_a.yaml -n redis-cluster --create-namespace --set global.redis.password=<your_password>

**For Cluster 1b**
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-1b
helm install redis-cluster-b ./charts -f ./charts/values_b.yaml -n redis-cluster --create-namespace --set global.redis.password=<your_password>

**Usage**
Once the Redis clusters are deployed, you can interact with them as follows:

**Connect to a Redis Pod:**
kubectl exec -it <pod_name> -n redis-cluster -- bash
redis-cli -c -h <headless-service or any service> -a <password>

**Check Redis Cluster Status:**
redis-cli -c -h <headless-service or any service> -a <password> CLUSTER NODES

Use redis-cli commands to check the status of the Redis cluster and perform operations.



