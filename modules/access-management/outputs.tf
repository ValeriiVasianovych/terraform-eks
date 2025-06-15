output "developer_access_key_id" {
  value       = aws_iam_access_key.developer.id
  description = "The access key ID for the developer user"
  sensitive   = false
}

output "developer_secret_access_key" {
  value       = aws_iam_access_key.developer.secret
  description = "The secret access key for the developer user"
  sensitive   = false
}
