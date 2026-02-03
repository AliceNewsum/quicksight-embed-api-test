# QuickSight Embed URL API - Terraform

This Terraform project deploys an API Gateway + Lambda solution for generating QuickSight anonymous embed URLs.

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│ API Gateway │────▶│   Lambda    │────▶│  QuickSight │
│  (Backend)  │     │  POST/embed │     │   Python    │     │  Dashboard  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                          │
                    ┌─────┴─────┐
                    │  API Key  │
                    │Usage Plan │
                    └───────────┘
```

## What Gets Created

| Resource | Name | Purpose |
|----------|------|---------|
| API Gateway | `quicksight-embed-url-api` | REST API with POST /embed |
| Lambda | `quicksight-generate-embed-url` | Generates embed URLs |
| IAM Role | `quicksight-generate-embed-url-role` | Lambda execution role |
| API Key | `quicksight-api-key` | Authentication (temporary) |
| Usage Plan | `quicksight-usage-plan` | Rate limiting (1 req/sec) |
| CloudWatch Logs | `/aws/lambda/quicksight-generate-embed-url` | Lambda logs |

## File Structure

```
quicksight-embed-terraform/
├── providers.tf               # Terraform and AWS provider config
├── data.tf                    # Data sources (account ID, region)
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output values after deployment
├── iam.tf                     # IAM role and policies
├── lambda.tf                  # Lambda function and permissions
├── cloudwatch.tf              # CloudWatch log group
├── api_gateway.tf             # API Gateway resources
├── terraform.tfvars.example   # Example variable values
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
└── lambda/
    └── handler.py             # Python Lambda code
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** v1.0.0 or later
3. **QuickSight (optional for testing)**: a QuickSight dashboard is required only for production use.
4. **QuickSight namespace (optional for testing)**: required only if you enable real QuickSight embedding.

## Deployment Steps

### Step 1: Clone and Configure

```bash
# Navigate to the project
cd quicksight-embed-terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### Step 2: Update terraform.tfvars

At minimum, you need to set:

```hcl
# Your dashboard ID from QuickSight
default_dashboard_id = "your-dashboard-id-here"

# Domains where embedding is allowed
allowed_domains = "https://your-app.com,https://localhost:3000"
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review the Plan

```bash
terraform plan
```

This shows what will be created. Review carefully!

### Step 5: Deploy

```bash
terraform apply
```

Type `yes` when prompted.

### Step 6: Note the Outputs

After deployment, you'll see:

```
api_endpoint = "https://abc123.execute-api.us-west-2.amazonaws.com/v1/embed"
api_key_id   = "abc123"
```

To get the API key value:

```bash
terraform output api_key_value
```

## Testing the API

```bash
# Get your API key
API_KEY=$(terraform output -raw api_key_value)

# Get the endpoint
ENDPOINT=$(terraform output -raw api_endpoint)

# Test the API
curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"dashboard_id": "your-dashboard-id"}'
```

Expected response:

```json
{
  "embedUrl": "https://us-west-2.quicksight.aws.amazon.com/embed/...",
  "status": 200,
  "requestId": "abc-123-def"
}

## Testing Without QuickSight (TEST MODE)

This repository includes a TEST-mode Lambda (`lambda/handler.py`) that returns a mock embed URL and does not call QuickSight. Use this to verify API Gateway + Lambda integration before wiring up real QuickSight resources.

- Ensure the deployed Lambda uses `lambda/handler.py` (the default in this repo).
- You can set environment variables locally or via Terraform to change defaults (`DEFAULT_DASHBOARD_ID`, `ALLOWED_DOMAINS`, `SESSION_LIFETIME_MINUTES`, `QUICKSIGHT_NAMESPACE`, `AWS_ACCOUNT_ID`).

Example test curl (same as above):

```bash
curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"dashboard_id": "test-dashboard"}'
```

Example TEST-mode response (mock):

```json
{
  "embedUrl": "https://us-west-2.quicksight.aws.amazon.com/embed/MOCK_URL_FOR_TESTING/test-dashboard",
  "status": 200,
  "requestId": "test-20250203123045",
  "testMode": true,
  "message": "This is a mock response. QuickSight is not configured.",
  "receivedConfig": {
    "dashboardId": "test-dashboard",
    "namespace": "default",
    "allowedDomains": ["https://localhost"],
    "sessionLifetimeMinutes": 60
  }
}
```

When you're ready to use real QuickSight, replace `lambda/handler.py` with your production handler and update permissions.
```

## Troubleshooting

### "Access Denied" from QuickSight

1. Check the dashboard is shared for anonymous embedding
2. Verify the namespace allows anonymous access
3. Confirm the IAM role has correct permissions

### "Invalid API Key"

1. Verify you're using `x-api-key` header (not `Authorization`)
2. Check the key is enabled: `terraform output api_key_id`
3. Verify the key is associated with the usage plan

### View Lambda Logs

```bash
aws logs tail /aws/lambda/quicksight-generate-embed-url --follow
```

## Security Notes

⚠️ **API Keys are Temporary**

This deployment uses API keys for simplicity, but they are **not a long-term security solution**. Plan to upgrade to:

- **IAM Authentication** - Best for backend-to-backend calls
- **Lambda Authorizer** - For custom auth logic
- **Private API** - For VPC-only access

The API key should **only** be used by your backend server, never exposed to browsers.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

## Customization

### Change Rate Limits

In `terraform.tfvars`:

```hcl
rate_limit  = 5   # requests per second
burst_limit = 20  # max concurrent
```

### Add More Dashboards

The Lambda accepts `dashboard_id` in the request body, so you can generate URLs for any dashboard. However, you need to update the IAM policy to allow access:

1. Add the dashboard ARN to `iam.tf` in the `lambda_permissions` policy
2. Run `terraform apply`

### Extend Session Lifetime

```hcl
session_lifetime_minutes = "120"  # 2 hours (max 600)
```
