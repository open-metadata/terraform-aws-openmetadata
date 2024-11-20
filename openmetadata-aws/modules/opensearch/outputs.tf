output "endpoint" {
  value = aws_opensearch_domain.opensearch.endpoint
}

output "port" {
  value = "443"
}

output "scheme" {
  value = "https"
}
