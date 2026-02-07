terraform {
  backend "s3" {
    bucket         = "eks-platform-terraform-state-398800073637"
    key            = "eks-platform/global/terraform.tfstate"  # SAME as terraform/core
    region         = "ap-south-1"
    dynamodb_table = "eks-platform-terraform-locks"
    encrypt        = true
  }
}