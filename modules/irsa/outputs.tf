output "role_arn" {
  description = "Annotate the Kubernetes ServiceAccount with this ARN (eks.amazonaws.com/role-arn)"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}