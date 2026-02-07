variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in VPC"
  default     = true
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnet internet access"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use single NAT Gateway instead of one per AZ"
  default     = true
}


# ==============================================================================
# EKS Cluster Variables
# ==============================================================================

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.28"
}

variable "enable_eks" {
  type        = bool
  description = "Enable EKS cluster deployment (set to false to save costs)"
  default     = false
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for EKS worker nodes"
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of EKS worker nodes"
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of EKS worker nodes"
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of EKS worker nodes"
}
