variable "cluster_name" {
  description = "Name of the EKS cluster this node group joins"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for worker nodes (private subnets — nodes should not be directly internet-facing)"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "SPOT"
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}