# =============================================================================
# Lambda Function
# =============================================================================

# -----------------------------------------------------------------------------
# Package Lambda Code
# -----------------------------------------------------------------------------

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

# -----------------------------------------------------------------------------
# Lambda Function
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "quicksight_embed" {
  function_name    = var.lambda_function_name
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn
  timeout          = var.lambda_timeout

  environment {
    variables = {
      AWS_ACCOUNT_ID           = data.aws_caller_identity.current.account_id
      QUICKSIGHT_NAMESPACE     = var.quicksight_namespace
      DEFAULT_DASHBOARD_ID     = var.default_dashboard_id
      ALLOWED_DOMAINS          = var.allowed_domains
      SESSION_LIFETIME_MINUTES = var.session_lifetime_minutes
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Lambda Permission for API Gateway
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quicksight_embed.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quicksight_api.execution_arn}/*/*"
}
