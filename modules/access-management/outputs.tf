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

output "manager_access_key_id" {
  value       = aws_iam_access_key.manager.id
  description = "The access key ID for the manager user"
  sensitive   = false
}

output "manager_secret_access_key" {
  value       = aws_iam_access_key.manager.secret
  description = "The secret access key for the manager user"
  sensitive   = false
}

# tester and programmer
output "tester_access_key_id" {
  value       = aws_iam_access_key.tester.id
  description = "The access key ID for the tester user"
  sensitive   = false
}

output "tester_secret_access_key" {
  value       = aws_iam_access_key.tester.secret
  description = "The secret access key for the tester user"
  sensitive   = false
}

output "programmer_access_key_id" {
  value       = aws_iam_access_key.programmer.id
  description = "The access key ID for the programmer user"
  sensitive   = false
}

output "programmer_secret_access_key" {
  value       = aws_iam_access_key.programmer.secret
  description = "The secret access key for the programmer user"
  sensitive   = false
}
