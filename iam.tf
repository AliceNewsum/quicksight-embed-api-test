# =============================================================================
# IAM Role and Policies for Lambda
# =============================================================================

# -----------------------------------------------------------------------------
# Trust Policy - Allows Lambda service to assume this role
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# -----------------------------------------------------------------------------
# Permissions Policy - What the Lambda can do
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_permissions" {
  # QuickSight embed URL generation
  # UNCOMMENT THIS BLOCK FOR PRODUCTION (when QuickSight is available)
  # statement {
  #   sid    = "AllowGenerateAnonymousEmbedUrl"
  #   effect = "Allow"
  #   actions = [
  #     "quicksight:GenerateEmbedUrlForAnonymousUser"
  #   ]
  #   resources = [
  #     "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:namespace/${var.quicksight_namespace}",
  #     "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dashboard/${var.default_dashboard_id}"
  #   ]
  # }

  # CloudWatch Logs for Lambda
  statement {
    sid    = "AllowBasicLambdaLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
    ]
  }
}

# -----------------------------------------------------------------------------
# IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "lambda_role" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Attach Permissions Policy to Role
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.lambda_function_name}-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}
