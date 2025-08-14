# Serverless Development Example

This example demonstrates how to use AWS SAM CLI for building, testing, and deploying serverless applications on AWS. It provides a complete development environment for serverless applications with local testing capabilities.

## Features Included

- **AWS SAM CLI** - Build and deploy serverless applications
- **AWS CLI** - AWS command-line interface for deployment and management
- **Docker-in-Docker** - For local testing and building containerized Lambda functions
- **Python 3.11** - Primary runtime for Lambda functions
- **AWS Toolkit for VS Code** - AWS integration in VS Code

## What's Included

This development container includes:
- Python 3.11 base image with pip and common packages
- AWS SAM CLI for serverless development
- AWS CLI for deployment and AWS service interaction
- Docker for local testing and container builds
- VS Code extensions for AWS development
- Pre-configured port forwarding for local development

## Quick Start

### 1. Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Initialize a New SAM Project

```bash
# Create a new SAM application
sam init

# Follow the interactive prompts:
# 1. Choose AWS Quick Start Templates
# 2. Choose a runtime (Python, Node.js, Java, etc.)
# 3. Select a template (Hello World, API Gateway, etc.)
# 4. Name your project
```

### 3. Explore the Generated Project

```bash
cd your-project-name

# Project structure:
# ├── hello_world/           # Lambda function code
# │   ├── app.py             # Function handler
# │   └── requirements.txt   # Python dependencies
# ├── events/                # Sample events for testing
# ├── tests/                 # Unit tests
# ├── template.yaml          # SAM template
# └── README.md             # Project documentation
```

### 4. Build and Test Locally

```bash
# Build the application
sam build

# Start API Gateway locally (runs on port 3000)
sam local start-api

# Test in another terminal
curl http://localhost:3000/hello
```

### 5. Deploy to AWS

```bash
# Deploy with guided prompts (first time)
sam deploy --guided

# Deploy with saved configuration
sam deploy
```

## Development Workflow

### Local Development

```bash
# Build the application
sam build

# Watch for changes and rebuild automatically
sam build --watch

# Start local API server
sam local start-api --host 0.0.0.0 --port 3000

# In another terminal, test your endpoints
curl http://localhost:3000/hello
curl -X POST http://localhost:3000/users -d '{"name": "John Doe"}'
```

### Testing Functions

```bash
# Invoke a function locally with an event
sam local invoke HelloWorldFunction -e events/event.json

# Generate sample events
sam local generate-event apigateway aws-proxy > events/api-event.json
sam local generate-event s3 put > events/s3-event.json

# Test with custom event
echo '{"key": "value"}' | sam local invoke HelloWorldFunction
```

### Debugging

```bash
# Start API with debugging enabled
sam local start-api --debug-port 5858

# Start Lambda service for debugging
sam local start-lambda --debug-port 5858

# Invoke function with debugging
sam local invoke -d 5858 HelloWorldFunction
```

## Example Projects

### 1. Hello World API

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Simple Hello World API

Globals:
  Function:
    Timeout: 10
    Runtime: python3.11

Resources:
  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: hello_world/
      Handler: app.lambda_handler
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get

Outputs:
  HelloWorldApi:
    Description: "API Gateway endpoint URL"
    Value: !Sub "https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/hello/"
```

```python
# hello_world/app.py
import json

def lambda_handler(event, context):
    """Sample Lambda function"""
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "message": "Hello, World!",
            "requestId": context.aws_request_id
        })
    }
```

### 2. REST API with DynamoDB

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  UsersTable:
    Type: AWS::Serverless::SimpleTable
    Properties:
      TableName: Users
      PrimaryKey:
        Name: userId
        Type: String

  CreateUserFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: functions/create_user/
      Handler: app.lambda_handler
      Runtime: python3.11
      Environment:
        Variables:
          USERS_TABLE: !Ref UsersTable
      Policies:
        - DynamoDBWritePolicy:
            TableName: !Ref UsersTable
      Events:
        CreateUser:
          Type: Api
          Properties:
            Path: /users
            Method: post

  GetUserFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: functions/get_user/
      Handler: app.lambda_handler
      Runtime: python3.11
      Environment:
        Variables:
          USERS_TABLE: !Ref UsersTable
      Policies:
        - DynamoDBReadPolicy:
            TableName: !Ref UsersTable
      Events:
        GetUser:
          Type: Api
          Properties:
            Path: /users/{userId}
            Method: get
```

### 3. Event-Driven Processing

```yaml
# template.yaml - S3 to Lambda processing
Resources:
  ProcessingBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${AWS::StackName}-processing-bucket"

  ProcessFileFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: functions/process_file/
      Handler: app.lambda_handler
      Runtime: python3.11
      Events:
        S3Event:
          Type: S3
          Properties:
            Bucket: !Ref ProcessingBucket
            Events: s3:ObjectCreated:*
            Filter:
              S3Key:
                Rules:
                  - Name: suffix
                    Value: .json
```

## Advanced Features

### Environment Variables and Configuration

```yaml
# template.yaml
Globals:
  Function:
    Environment:
      Variables:
        LOG_LEVEL: INFO
        STAGE: !Ref Stage

Parameters:
  Stage:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
```

### Lambda Layers

```yaml
# template.yaml
Resources:
  SharedLibraryLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: shared-libraries
      Description: Shared Python libraries
      ContentUri: layers/shared-libs/
      CompatibleRuntimes:
        - python3.11

  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Layers:
        - !Ref SharedLibraryLayer
```

### Step Functions

```yaml
# template.yaml
Resources:
  ProcessingStateMachine:
    Type: AWS::Serverless::StateMachine
    Properties:
      DefinitionUri: statemachine/process_data.asl.json
      DefinitionSubstitutions:
        ProcessFunctionArn: !GetAtt ProcessFunction.Arn
      Policies:
        - LambdaInvokePolicy:
            FunctionName: !Ref ProcessFunction
```

## Testing

### Unit Tests

```python
# tests/unit/test_handler.py
import json
import pytest
from hello_world import app

def test_lambda_handler():
    event = {
        "httpMethod": "GET",
        "path": "/hello",
        "headers": {},
        "queryStringParameters": None,
        "body": None
    }
    
    context = {}
    
    ret = app.lambda_handler(event, context)
    data = json.loads(ret["body"])
    
    assert ret["statusCode"] == 200
    assert "message" in data
    assert data["message"] == "Hello, World!"
```

### Integration Tests

```python
# tests/integration/test_api_gateway.py
import requests

def test_api_gateway():
    """Test the actual API Gateway endpoint"""
    # This assumes your API is running locally
    response = requests.get("http://localhost:3000/hello")
    
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
```

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-mock

# Run unit tests
python -m pytest tests/unit -v

# Run integration tests (with local API running)
sam local start-api &
python -m pytest tests/integration -v
pkill -f "sam local start-api"
```

## Deployment Strategies

### Multi-Environment Deployment

```bash
# Deploy to development
sam deploy --config-env dev

# Deploy to staging
sam deploy --config-env staging

# Deploy to production
sam deploy --config-env prod
```

### CI/CD with GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy SAM Application

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          
      - name: Setup SAM CLI
        uses: aws-actions/setup-sam@v2
        
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Build and deploy
        run: |
          sam build
          sam deploy --no-confirm-changeset --no-fail-on-empty-changeset
```

## Monitoring and Observability

### CloudWatch Integration

```yaml
# template.yaml
Globals:
  Function:
    Tracing: Active  # Enable X-Ray tracing
    Environment:
      Variables:
        POWERTOOLS_SERVICE_NAME: MyService
        POWERTOOLS_LOG_LEVEL: INFO

Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Environment:
        Variables:
          POWERTOOLS_METRICS_NAMESPACE: MyApp
```

### Application Insights

```python
# Using AWS Lambda Powertools
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger()
tracer = Tracer()
metrics = Metrics()

@logger.inject_lambda_context
@tracer.capture_lambda_handler
@metrics.log_metrics
def lambda_handler(event, context):
    logger.info("Processing request", extra={"request_id": context.aws_request_id})
    
    metrics.add_metric(name="RequestsProcessed", unit=MetricUnit.Count, value=1)
    
    # Your function logic here
    
    return {"statusCode": 200, "body": "Success"}
```

## Best Practices

### 1. Project Structure
```
serverless-app/
├── functions/
│   ├── create_user/
│   ├── get_user/
│   └── shared/          # Shared utilities
├── layers/
│   └── shared-libs/
├── tests/
│   ├── unit/
│   └── integration/
├── events/              # Sample events
├── statemachines/       # Step Functions definitions
├── template.yaml        # SAM template
└── samconfig.toml      # SAM configuration
```

### 2. Configuration Management
- Use parameter store or environment variables
- Separate configuration per environment
- Keep secrets in AWS Secrets Manager

### 3. Security
- Use least privilege IAM policies
- Enable AWS X-Ray for tracing
- Implement proper error handling
- Validate input data

### 4. Performance
- Optimize cold starts
- Use provisioned concurrency for critical functions
- Implement connection pooling for databases
- Monitor and optimize memory allocation

## Troubleshooting

### Common Issues

1. **SAM build failures**
   ```bash
   # Clear build cache
   sam build --cache-dir .aws-sam/cache --cached
   
   # Build with container
   sam build --use-container
   ```

2. **Local API not accessible**
   ```bash
   # Use host 0.0.0.0 to bind to all interfaces
   sam local start-api --host 0.0.0.0
   ```

3. **Permission errors during deployment**
   ```bash
   # Check IAM permissions
   aws sts get-caller-identity
   
   # Ensure proper CloudFormation permissions
   ```

This example provides a comprehensive serverless development environment with AWS SAM CLI!
