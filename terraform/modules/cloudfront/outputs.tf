output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "s3_bucket_name" {
  description = "Static assets S3 bucket name"
  value       = aws_s3_bucket.static_assets.id
}

output "s3_bucket_arn" {
  description = "Static assets S3 bucket ARN"
  value       = aws_s3_bucket.static_assets.arn
}
