provider "helm" {
  kubernetes {
    host                   = try(module.eks_cluster[0].cluster_endpoint, "")
    cluster_ca_certificate = try(base64decode(module.eks_cluster[0].cluster_certificate_authority_data), "")

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name,
        "--region",
        "ap-south-1"
      ]
    }
  }
}