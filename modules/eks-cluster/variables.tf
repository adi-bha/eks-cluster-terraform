variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane"
  type        = string
  default     = "1.30"
}

variable "subnet_ids" {
  description = "Subnet IDs the control plane ENIs will use (typically private subnets; include public if you want public endpoint access from specific subnets)"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the cluster API endpoint is reachable from the internet (true is simpler for learning; restrict via endpoint_public_access_cidrs for anything beyond a throwaway cluster)"
  type        = bool
  default     = true
}