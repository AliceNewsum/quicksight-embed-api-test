"""
QuickSight Anonymous Embed URL Generator - TEST MODE

This is a TEST version that returns mock responses without calling QuickSight.
Use this to verify API Gateway and Lambda integration works.

When ready for production:
  1. Replace this file with handler_production.py
  2. Redeploy with: terraform apply
"""

import json
import os
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    TEST Lambda handler - returns mock embed URL response.
    """
    logger.info("Processing embed URL request (TEST MODE)")
    
    try:
        # Parse request body
        body = parse_request_body(event)
        
        # Get configuration from environment
        account_id = os.environ.get('AWS_ACCOUNT_ID', '123456789012')
        namespace = os.environ.get('QUICKSIGHT_NAMESPACE', 'default')
        default_dashboard_id = os.environ.get('DEFAULT_DASHBOARD_ID', 'test-dashboard')
        allowed_domains = os.environ.get('ALLOWED_DOMAINS', 'https://localhost')
        session_lifetime = os.environ.get('SESSION_LIFETIME_MINUTES', '60')
        
        # Get dashboard ID from request or use default
        dashboard_id = body.get('dashboard_id') or default_dashboard_id
        
        # Log what we received (for testing)
        logger.info(f"TEST MODE - Would generate embed URL for:")
        logger.info(f"  Account ID: {account_id}")
        logger.info(f"  Namespace: {namespace}")
        logger.info(f"  Dashboard ID: {dashboard_id}")
        logger.info(f"  Allowed Domains: {allowed_domains}")
        logger.info(f"  Session Lifetime: {session_lifetime} minutes")
        
        # Return mock response
        mock_response = {
            'embedUrl': f'https://us-west-2.quicksight.aws.amazon.com/embed/MOCK_URL_FOR_TESTING/{dashboard_id}',
            'status': 200,
            'requestId': f'test-{datetime.utcnow().strftime("%Y%m%d%H%M%S")}',
            'testMode': True,
            'message': 'This is a mock response. QuickSight is not configured.',
            'receivedConfig': {
                'dashboardId': dashboard_id,
                'namespace': namespace,
                'allowedDomains': allowed_domains.split(','),
                'sessionLifetimeMinutes': int(session_lifetime)
            }
        }
        
        logger.info("TEST MODE - Returning mock response")
        return success_response(mock_response)
        
    except json.JSONDecodeError:
        logger.error("Invalid JSON in request body")
        return error_response(400, "Invalid JSON in request body")
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return error_response(500, f"Internal server error: {str(e)}")


def parse_request_body(event):
    """Parse the request body from API Gateway event."""
    body = event.get('body')
    
    if not body:
        return {}
    
    if isinstance(body, str):
        return json.loads(body)
    return body


def success_response(data):
    """Build a successful API Gateway proxy response."""
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Api-Key',
            'Access-Control-Allow-Methods': 'POST,OPTIONS'
        },
        'body': json.dumps(data)
    }


def error_response(status_code, message):
    """Build an error API Gateway proxy response."""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Api-Key',
            'Access-Control-Allow-Methods': 'POST,OPTIONS'
        },
        'body': json.dumps({
            'error': message
        })
    }
