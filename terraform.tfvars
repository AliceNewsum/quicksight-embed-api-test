# =============================================================================
# QuickSight Embed URL API - Example Variable Values
# =============================================================================
# 
# HOW TO USE:
#   1. Copy this file: cp terraform.tfvars.example terraform.tfvars
#   2. Edit terraform.tfvars with your actual values
#   3. Run: terraform plan
#   4. Run: terraform apply
#
# IMPORTANT: Never commit terraform.tfvars to git (it may contain secrets)
# =============================================================================

# -----------------------------------------------------------------------------
# REQUIRED - You must provide these values
# -----------------------------------------------------------------------------

# Your QuickSight dashboard ID
# Find this in the QuickSight console URL when viewing the dashboard
# Example: https://us-west-2.quicksight.aws.amazon.com/sn/dashboards/98dad6e6-c96f-49e6-b239-fe50e0b58e76
default_dashboard_id = "98dad6e6-c96f-49e6-b239-fe50e0b58e76"

# Domains allowed to embed the dashboard
# Must include the protocol (https://)
# Separate multiple domains with commas, no spaces
allowed_domains = "https://your-app.example.com,https://localhost:3000"

# -----------------------------------------------------------------------------
# OPTIONAL - These have sensible defaults but you can override
# -----------------------------------------------------------------------------

# AWS region (must match where your QuickSight is set up)
aws_region = "us-west-2"

# QuickSight namespace
quicksight_namespace = "default"

# Session lifetime (15-600 minutes)
session_lifetime_minutes = "60"

# API rate limiting
rate_limit  = 1   # requests per second
burst_limit = 10  # max concurrent

# Log retention
log_retention_days = 14

# Resource tags
tags = {
  Project     = "quicksight-embed"
  ManagedBy   = "terraform"
  Environment = "production"
  Owner       = "your-team"
}
