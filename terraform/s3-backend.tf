terraform {
  backend "s3" {
    bucket  = "tf-statefilebucket"
    key     = "terraform/state/eks-cluster.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
