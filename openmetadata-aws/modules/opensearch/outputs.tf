output "opensearch_endpoint" {
  value = aws_opensearch_domain.opensearch.endpoint
}

output "opensearch_port" {
  value = "443"
}

output "opensearch_scheme" {
  value = "https"
}
