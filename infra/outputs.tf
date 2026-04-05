output "api_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.items.name
}
