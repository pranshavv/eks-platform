terraform {
  backend "s3" {
    bucket         = "eks-platform-terraform-state-398800073637"
    key            = "envs/prod/terraform.tfstate"  # Different state file
    region         = "ap-south-1"
    dynamodb_table = "eks-platform-terraform-locks"
    encrypt        = true
  }
}