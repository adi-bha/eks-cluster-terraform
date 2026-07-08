variable "role_name" {
  description = "Name for the IAM role (e.g. 'aws-load-balancer-controller')"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN, from the eks-cluster module output"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL without https:// prefix, from the eks-cluster module output"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount this role is for"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes ServiceAccount this role is for"
  type        = string
}

variable "policy_arns" {
  description = "IAM policy ARNs to attach to this role"
  type        = list(string)
  default     = []
}