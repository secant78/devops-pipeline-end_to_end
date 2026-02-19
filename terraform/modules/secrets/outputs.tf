output "db_credentials_arn" {
  description = "DB credentials secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_config_arn" {
  description = "Redis config secret ARN"
  value       = aws_secretsmanager_secret.redis_config.arn
}

output "api_keys_arn" {
  description = "API keys secret ARN"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "secrets_access_policy_arn" {
  description = "IAM policy ARN for secrets access"
  value       = aws_iam_policy.secrets_access.arn
}
