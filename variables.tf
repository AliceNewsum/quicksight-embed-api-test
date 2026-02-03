# =============================================================================
# QuickSight Embed URL API - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# GENERAL
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "quicksight-embed"
    ManagedBy   = "terraform"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# QUICKSIGHT CONFIGURATION
# -----------------------------------------------------------------------------

variable "quicksight_namespace" {
  description = "QuickSight namespace (typically 'default')"
  type        = string
  default     = "default"
}

variable "default_dashboard_id" {
  description = "ID of the QuickSight dashboard to embed"
  type        = string
  # No default - must be provided
}

variable "allowed_domains" {
  description = "Comma-separated list of domains allowed to embed the dashboard"
  type        = string
  # Example: "https://example.com,https://app.example.com"
}

variable "session_lifetime_minutes" {
  description = "Embed session duration in minutes (15-600)"
  type        = string
  default     = "60"
}

# -----------------------------------------------------------------------------
# LAMBDA CONFIGURATION
# -----------------------------------------------------------------------------

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "quicksight-generate-embed-url"
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
  default     = "quicksight-generate-embed-url-role"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# -----------------------------------------------------------------------------
# API GATEWAY CONFIGURATION
# -----------------------------------------------------------------------------

variable "api_gateway_name" {
  description = "Name of the API Gateway REST API"
  type        = string
  default     = "quicksight-embed-url-api"
}

variable "api_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "v1"
}

# -----------------------------------------------------------------------------
# API KEY AND USAGE PLAN
# -----------------------------------------------------------------------------

variable "api_key_name" {
  description = "Name of the API key"
  type        = string
  default     = "quicksight-api-key"
}

variable "usage_plan_name" {
  description = "Name of the usage plan"
  type        = string
  default     = "quicksight-usage-plan"
}

variable "rate_limit" {
  description = "API rate limit (requests per second)"
  type        = number
  default     = 1
}

variable "burst_limit" {
  description = "API burst limit (maximum concurrent requests)"
  type        = number
  default     = 10
}
