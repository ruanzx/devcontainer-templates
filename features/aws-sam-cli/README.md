# AWS SAM CLI Feature

This feature installs the [AWS Serverless Application Model (SAM) CLI](https://docs.aws.amazon.com/serverless-application-model/), a command-line tool for building and deploying serverless applications on AWS.

## Description

AWS SAM CLI provides a Lambda-like execution environment that lets you locally build, test, debug, and deploy applications defined by SAM templates. It extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application.

## Key Features

- **Local Development**: Build and test serverless applications locally
- **Easy Deployment**: Deploy applications to AWS with simple commands
- **Template Support**: Use SAM templates for infrastructure as code
- **Event Simulation**: Test Lambda functions with sample events
- **API Gateway Local**: Run API Gateway locally for development
- **Step Functions Support**: Local testing of Step Functions
- **Layer Management**: Build and deploy Lambda layers

## Options

### `version` (string)
Select the version of AWS SAM CLI to install.

- **Default**: `latest`
- **Options**: `latest`, `1.126.0`, `1.125.0`, `1.124.0`, `1.123.0`

### `installDocker` (boolean)
Install Docker (required for local testing and building).

- **Default**: `true`
- **Description**: Docker is required for SAM local commands and building functions

## Prerequisites

AWS SAM CLI requires:
- **Python 3.8+** (installed automatically)
- **Docker** (optional but recommended for local development)
- **AWS CLI** (recommended for deployment)

## Quick Start

### 1. Initialize a New Project

```bash
# Create a new SAM application
sam init

# Choose from available templates:
# - Hello World Example
# - Machine Learning Inference API
# - Quick Start templates for various runtimes
```

### 2. Build Your Application

```bash
# Build the application
sam build

# Build with specific parameters
sam build --use-container  # Build using Docker containers
sam build --parallel       # Build functions in parallel
```

### 3. Test Locally

```bash
# Start API Gateway locally
sam local start-api

# Invoke a specific function locally
sam local invoke "HelloWorldFunction" -e events/event.json

# Start local Lambda service
sam local start-lambda
```

### 4. Deploy to AWS

```bash
# Guided deployment (first time)
sam deploy --guided

# Deploy with saved parameters
sam deploy

# Deploy to specific stack
sam deploy --stack-name my-stack
```

## Common SAM Commands

### Project Management
```bash
# Initialize new project
sam init

# Validate SAM template
sam validate

# Generate sample events
sam local generate-event apigateway aws-proxy
```

### Local Development
```bash
# Build application
sam build

# Start API Gateway locally (default: http://127.0.0.1:3000)
sam local start-api

# Start Lambda service locally
sam local start-lambda

# Invoke function with event
sam local invoke FunctionName -e event.json
```

### Deployment
```bash
# Package application
sam package --s3-bucket my-bucket

# Deploy application
sam deploy --guided
sam deploy --stack-name my-stack --capabilities CAPABILITY_IAM

# Delete stack
sam delete --stack-name my-stack
```

### Logs and Monitoring
```bash
# Fetch function logs
sam logs -n HelloWorldFunction --stack-name my-stack

# Tail logs in real-time
sam logs -n HelloWorldFunction --stack-name my-stack --tail
```

## Example SAM Template

Here's a basic SAM template (`template.yaml`):

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Simple SAM application

Globals:
  Function:
    Timeout: 3
    Runtime: python3.9

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

  DynamoDBTable:
    Type: AWS::Serverless::SimpleTable
    Properties:
      TableName: MyTable
      PrimaryKey:
        Name: id
        Type: String

Outputs:
  HelloWorldApi:
    Description: "API Gateway endpoint URL"
    Value: !Sub "https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/hello/"
```

## Example Python Lambda Function

```python
# hello_world/app.py
import json

def lambda_handler(event, context):
    """Sample pure Lambda function"""
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "hello world",
            "event": event
        }),
    }
```

## Development Workflow

### 1. Project Setup
```bash
# Create new project
sam init --runtime python3.9 --name my-sam-app
cd my-sam-app

# Install dependencies
pip install -r requirements.txt
```

### 2. Local Development
```bash
# Build the application
sam build

# Test API locally
sam local start-api &

# Test endpoints
curl http://127.0.0.1:3000/hello

# Stop local API
pkill -f "sam local start-api"
```

### 3. Testing
```bash
# Generate test events
sam local generate-event apigateway aws-proxy > event.json

# Test function with event
sam local invoke HelloWorldFunction -e event.json

# Unit testing
python -m pytest tests/
```

### 4. Deployment
```bash
# First deployment (guided)
sam deploy --guided

# Subsequent deployments
sam deploy

# Monitor logs
sam logs -n HelloWorldFunction --tail
```

## Advanced Features

### Environment Variables
```yaml
Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Environment:
        Variables:
          TABLE_NAME: !Ref DynamoDBTable
          STAGE: !Ref Stage
```

### Lambda Layers
```yaml
Resources:
  SharedLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: shared-dependencies
      ContentUri: layers/shared/
      CompatibleRuntimes:
        - python3.9

  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Layers:
        - !Ref SharedLayer
```

### Step Functions
```yaml
Resources:
  MyStateMachine:
    Type: AWS::Serverless::StateMachine
    Properties:
      DefinitionUri: statemachine.asl.json
      Policies:
        - LambdaInvokePolicy:
            FunctionName: !Ref ProcessFunction
```

## Integration with Other Tools

### VS Code Extensions
- **AWS Toolkit**: SAM project management
- **AWS SAM CLI**: Command palette integration

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Build SAM application
  run: sam build

- name: Deploy SAM application
  run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset
```

## Troubleshooting

### Common Issues

1. **Docker not running**
   ```
   Error: Could not connect to Docker daemon
   ```
   - Ensure Docker is installed and running
   - Check Docker permissions

2. **Port already in use**
   ```
   Error: Port 3000 is already in use
   ```
   - Use `--port` flag: `sam local start-api --port 3001`
   - Kill existing processes using the port

3. **Build failures**
   ```
   Error: Build failed
   ```
   - Check `requirements.txt` for Python projects
   - Verify template syntax with `sam validate`
   - Use `--use-container` flag for consistent builds

4. **Deployment failures**
   ```
   Error: Stack creation failed
   ```
   - Check IAM permissions
   - Verify AWS credentials configuration
   - Review CloudFormation events in AWS Console

## More Information

- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/)
- [SAM CLI Reference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
- [SAM Template Specification](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification.html)
- [AWS SAM Examples](https://github.com/aws/aws-sam-cli/tree/develop/samcli/local/init/templates)
- [Serverless Patterns](https://serverlessland.com/patterns)
