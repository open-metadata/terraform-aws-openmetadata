output "endpoint" {
  description = "The endpoint of the OpenSearch domain"
  value       = aws_opensearch_domain.opensearch.endpoint
}

output "port" {
  description = "The port of the OpenSearch domain. Hardcoded to 443"
  value       = "443"
}

output "scheme" {
  description = "The scheme of the OpenSearch domain. Hardcoded to https"
  value       = "https"
}
