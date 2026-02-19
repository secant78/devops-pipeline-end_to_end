output "sqs_queue_urls" {
  description = "Map of SQS queue URLs"
  value = {
    order_processing   = aws_sqs_queue.order_processing.url
    payment_processing = aws_sqs_queue.payment_processing.url
    notifications      = aws_sqs_queue.notification_queue.url
  }
}

output "sqs_queue_arns" {
  description = "Map of SQS queue ARNs"
  value = {
    order_processing   = aws_sqs_queue.order_processing.arn
    payment_processing = aws_sqs_queue.payment_processing.arn
    notifications      = aws_sqs_queue.notification_queue.arn
  }
}

output "sns_topic_arns" {
  description = "Map of SNS topic ARNs"
  value = {
    order_events     = aws_sns_topic.order_events.arn
    payment_events   = aws_sns_topic.payment_events.arn
    inventory_events = aws_sns_topic.inventory_events.arn
  }
}
