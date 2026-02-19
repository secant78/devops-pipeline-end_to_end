# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Failed Nodes"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.cluster_name}-primary"],
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "${var.cluster_name}-primary"],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.cluster_name}-primary"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "${var.cluster_name}-sessions"],
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", "${var.cluster_name}-sessions"],
            ["AWS/ElastiCache", "CacheHitRate", "CacheClusterId", "${var.cluster_name}-sessions"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ElastiCache Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id],
            ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.cloudfront_distribution_id],
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.cloudfront_distribution_id]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "CloudFront Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", "${var.cluster_name}-order-processing"],
            ["AWS/SQS", "NumberOfMessagesReceived", "QueueName", "${var.cluster_name}-order-processing"],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.cluster_name}-order-processing"]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "SQS Order Queue Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.cluster_name}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is above 80%"

  dimensions = {
    DBInstanceIdentifier = "${var.cluster_name}-primary"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.cluster_name}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "RDS connection count is above 50"

  dimensions = {
    DBInstanceIdentifier = "${var.cluster_name}-primary"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq" {
  alarm_name          = "${var.cluster_name}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages in dead letter queue"

  dimensions = {
    QueueName = "${var.cluster_name}-order-processing-dlq"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# SNS topic for CloudWatch alarms
resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-cloudwatch-alerts"

  tags = {
    Name        = "${var.cluster_name}-alerts"
    Environment = var.environment
  }
}

# CloudWatch Log Groups for microservices
resource "aws_cloudwatch_log_group" "microservices" {
  for_each = toset(["user-service", "product-service", "cart-service", "payment-service", "order-service"])

  name              = "/eks/${var.cluster_name}/${each.key}"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    Service     = each.key
  }
}
