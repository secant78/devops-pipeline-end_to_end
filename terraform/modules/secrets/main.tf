resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.cluster_name}/db-credentials"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.cluster_name}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_endpoint
    port     = 5432
    dbname   = "ecommerce"
  })
}

resource "aws_secretsmanager_secret" "redis_config" {
  name                    = "${var.cluster_name}/redis-config"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.cluster_name}-redis-config"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "redis_config" {
  secret_id = aws_secretsmanager_secret.redis_config.id

  secret_string = jsonencode({
    host = var.redis_endpoint
    port = 6379
  })
}

resource "aws_secretsmanager_secret" "api_keys" {
  name                    = "${var.cluster_name}/api-keys"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.cluster_name}-api-keys"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id

  secret_string = jsonencode({
    jwt_secret      = "REPLACE_WITH_ACTUAL_SECRET"
    payment_api_key = "REPLACE_WITH_ACTUAL_KEY"
  })
}

# IAM policy for EKS pods to access secrets
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.cluster_name}-secrets-access"
  description = "Allow EKS pods to read secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.db_credentials.arn,
          aws_secretsmanager_secret.redis_config.arn,
          aws_secretsmanager_secret.api_keys.arn
        ]
      }
    ]
  })
}
