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