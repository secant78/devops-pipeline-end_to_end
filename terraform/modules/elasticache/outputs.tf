output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_cluster.session_store.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.session_store.port
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}
