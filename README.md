

**Redis Infrastructure DevOps**
This repository provides Terraform and Helm configurations for setting up and managing Redis infrastructure on AWS EKS clusters. It includes scripts for operational tasks and GitHub Actions workflows for CI/CD.

**Table of Contents**
Introduction
Prerequisites
Repository Structure
Setup Instructions
Usage
CI/CD Workflows
Contributing
License
Introduction
This repository is designed to help you deploy and manage Redis on AWS EKS clusters using Terraform and Helm. It includes configurations for two EKS clusters and Helm charts for Redis deployment. Scripts and GitHub Actions workflows are also provided to facilitate management and deployment tasks.

**Overview**
This repository provides the tools and configurations necessary to deploy a Redis cluster across two EKS clusters. Key features include:

# Cluster Configuration: Two EKS clusters are created and configured to work together in a high-availability setup.
# Redis Interaction: You can interact with the Redis cluster by connecting to any Redis pod and using redis-cli.
# Data Persistence: Redis data is persisted using EBS volumes with the Append-Only File (AOF) mechanism to ensure data durability.


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
    ├── eks.tf
    │   └── Main Terraform configuration file.
    ├── variables.tf
    │   └── Variables for Terraform configurations.
    ├── Network.tf
    │   └── All Networking from Terraform configurations.
    └── security-groups.tf
        └── Security group rules for EKS clusters.

scripts/
    └── coredns_change.sh
        └── Script for updating CoreDNS configurations.

.github/
    └── workflows/
        └── main.yml
            └── Main GitHub Actions workflow file.


bash
Copy code
git clone https://github.com/mohdalmas/redis-infra-devops.git
cd redis-infra-devops
Setup Terraform:

Initialize Terraform and apply the configurations to set up the infrastructure:

bash
Copy code
terraform init
terraform apply
Deploy Redis Using Helm:

Update the Helm chart values for your specific clusters and install Redis:

bash
Copy code
# For Cluster 1a
helm install redis-cluster-a ./charts -f ./charts/values_a.yaml -n redis-cluster --create-namespace --set global.redis.password=<your_password>

# For Cluster 1b
helm install redis-cluster-b ./charts -f ./charts/values_b.yaml -n redis-cluster --create-namespace --set global.redis.password=<your_password>
Usage
Once the Redis clusters are deployed, you can interact with them as follows:

Connect to a Redis Pod:

bash
Copy code
kubectl exec -it <pod_name> -n redis-cluster -- redis-cli
Check Redis Cluster Status:

Use redis-cli commands to check the status of the Redis cluster and perform operations.

CI/CD Workflows
This repository uses GitHub Actions for continuous integration and deployment. The workflows are defined in .github/workflows/main.yml and include steps for deploying infrastructure and applications.

Contributing
Contributions to this repository are welcome! Please follow the standard GitHub workflow for contributing:

Fork the repository.
Create a feature branch.
Commit your changes.
Push to the feature branch.
Create a pull request.
License
This project is licensed under the MIT License. See the LICENSE file for more details.

