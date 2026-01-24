data "terraform_remote_state" "core" {
  backend = "s3"
  
  config = {
    bucket         = "eks-platform-terraform-state-398800073637"
    key            = "eks-platform/global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "eks-platform-terraform-locks"
    encrypt        = true
  }
}
