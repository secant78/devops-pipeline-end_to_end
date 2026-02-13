# SNS Topics for event-driven architecture
resource "aws_sns_topic" "order_events" {
  name = "${var.cluster_name}-order-events"

  tags = {
    Name        = "${var.cluster_name}-order-events"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "payment_events" {
  name = "${var.cluster_name}-payment-events"

  tags = {
    Name        = "${var.cluster_name}-payment-events"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "inventory_events" {
  name = "${var.cluster_name}-inventory-events"

  tags = {
    Name        = "${var.cluster_name}-inventory-events"
    Environment = var.environment
  }
}

# SQS Queues for microservice communication
resource "aws_sqs_queue" "order_processing" {
  name                       = "${var.cluster_name}-order-processing"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60

  tags = {
    Name        = "${var.cluster_name}-order-processing"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "order_processing_dlq" {
  name                      = "${var.cluster_name}-order-processing-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.cluster_name}-order-processing-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue_redrive_policy" "order_processing" {
  queue_url = aws_sqs_queue.order_processing.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_processing_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "payment_processing" {
  name                       = "${var.cluster_name}-payment-processing"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60

  tags = {
    Name        = "${var.cluster_name}-payment-processing"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "notification_queue" {
  name                       = "${var.cluster_name}-notifications"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30

  tags = {
    Name        = "${var.cluster_name}-notifications"
    Environment = var.environment
  }
}

# SNS to SQS subscriptions
resource "aws_sns_topic_subscription" "order_to_processing" {
  topic_arn = aws_sns_topic.order_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_processing.arn
}

resource "aws_sns_topic_subscription" "payment_to_processing" {
  topic_arn = aws_sns_topic.payment_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_processing.arn
}

# SQS policies to allow SNS to send messages
resource "aws_sqs_queue_policy" "order_processing" {
  queue_url = aws_sqs_queue.order_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSNS"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.order_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.order_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "payment_processing" {
  queue_url = aws_sqs_queue.payment_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSNS"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.payment_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.payment_events.arn
          }
        }
      }
    ]
  })
}
