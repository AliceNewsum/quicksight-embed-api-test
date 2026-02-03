# =============================================================================
# API Gateway REST API
# =============================================================================

# -----------------------------------------------------------------------------
# REST API
# -----------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "quicksight_api" {
  name        = var.api_gateway_name
  description = "API for generating QuickSight anonymous embed URLs"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Resource: /embed
# -----------------------------------------------------------------------------

resource "aws_api_gateway_resource" "embed" {
  rest_api_id = aws_api_gateway_rest_api.quicksight_api.id
  parent_id   = aws_api_gateway_rest_api.quicksight_api.root_resource_id
  path_part   = "embed"
}

# -----------------------------------------------------------------------------
# Request Validator
# -----------------------------------------------------------------------------

resource "aws_api_gateway_request_validator" "validate_body" {
  name                        = "validate-body"
  rest_api_id                 = aws_api_gateway_rest_api.quicksight_api.id
  validate_request_body       = true
  validate_request_parameters = false
}

# -----------------------------------------------------------------------------
# Method: POST /embed
# -----------------------------------------------------------------------------

resource "aws_api_gateway_method" "embed_post" {
  rest_api_id          = aws_api_gateway_rest_api.quicksight_api.id
  resource_id          = aws_api_gateway_resource.embed.id
  http_method          = "POST"
  authorization        = "NONE"
  api_key_required     = true
  request_validator_id = aws_api_gateway_request_validator.validate_body.id
}

# -----------------------------------------------------------------------------
# Lambda Integration (Proxy)
# -----------------------------------------------------------------------------

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.quicksight_api.id
  resource_id             = aws_api_gateway_resource.embed.id
  http_method             = aws_api_gateway_method.embed_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.quicksight_embed.invoke_arn
}

# -----------------------------------------------------------------------------
# Deployment
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.quicksight_api.id

  # Redeploy when these resources change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.embed.id,
      aws_api_gateway_method.embed_post.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.embed_post,
    aws_api_gateway_integration.lambda_integration
  ]
}

# -----------------------------------------------------------------------------
# Stage
# -----------------------------------------------------------------------------

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.quicksight_api.id
  stage_name    = var.api_stage_name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# API Key
# -----------------------------------------------------------------------------

resource "aws_api_gateway_api_key" "quicksight_key" {
  name        = var.api_key_name
  description = "API key for QuickSight embed URL generation - backend use only"
  enabled     = true

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Usage Plan
# -----------------------------------------------------------------------------

resource "aws_api_gateway_usage_plan" "quicksight_plan" {
  name        = var.usage_plan_name
  description = "Usage plan for QuickSight embed API with rate limiting"

  api_stages {
    api_id = aws_api_gateway_rest_api.quicksight_api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }

  throttle_settings {
    rate_limit  = var.rate_limit
    burst_limit = var.burst_limit
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Associate API Key with Usage Plan
# -----------------------------------------------------------------------------

resource "aws_api_gateway_usage_plan_key" "quicksight_plan_key" {
  key_id        = aws_api_gateway_api_key.quicksight_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.quicksight_plan.id
}
