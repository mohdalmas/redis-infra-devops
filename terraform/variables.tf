variable "region" {
  default     = "us-east-1"
  description = "AWS Region Name"

}

variable "account_id" {
  default     = "194722417082"
  description = "AWS Account Name"

}

variable "cluster_name" {
  description = "EKS Cluster Name"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_names" {
  description = "List of names for public subnets"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "List of names for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to deploy subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

# General Tags for Resources
variable "default_tags" {
  description = "Default tags for resources"
  type        = map(string)
}

