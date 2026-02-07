variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
}

variable "azs" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags applied to all VPC resources"
  type        = map(string)
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnet internet access"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use single NAT Gateway instead of one per AZ (cost optimization)"
  default     = true
}