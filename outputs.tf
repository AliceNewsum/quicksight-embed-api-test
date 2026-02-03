# =============================================================================
# QuickSight Embed URL API - Outputs
# =============================================================================
# These values are displayed after terraform apply
# =============================================================================

output "api_endpoint" {
  description = "Full URL to call the embed API"
  value       = "${aws_api_gateway_stage.api_stage.invoke_url}/embed"
}

output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.quicksight_api.id
}

output "api_key_id" {
  description = "API key ID (use 'terraform output api_key_value' to see the actual key)"
  value       = aws_api_gateway_api_key.quicksight_key.id
}

output "api_key_value" {
  description = "API key value - KEEP THIS SECRET"
  value       = aws_api_gateway_api_key.quicksight_key.value
  sensitive   = true
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.quicksight_embed.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.quicksight_embed.arn
}

output "lambda_role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.lambda_role.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for Lambda logs"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

# -----------------------------------------------------------------------------
# USAGE INSTRUCTIONS
# -----------------------------------------------------------------------------

output "usage_instructions" {
  description = "How to test the API"
  value       = <<-EOT
    
    ========================================
    DEPLOYMENT COMPLETE!
    ========================================
    
    To test the API, run:
    
    curl -X POST "${aws_api_gateway_stage.api_stage.invoke_url}/embed" \
      -H "Content-Type: application/json" \
      -H "x-api-key: $(terraform output -raw api_key_value)" \
      -d '{"dashboard_id": "${var.default_dashboard_id}"}'
    
    To view the API key:
      terraform output api_key_value
    
    To view Lambda logs:
      aws logs tail /aws/lambda/${var.lambda_function_name} --follow
    
    ========================================
    SECURITY NOTE
    ========================================
    API keys are temporary. Plan to replace with:
    - IAM authentication
    - Lambda authorizer
    - Private API endpoint
    
  EOT
}
