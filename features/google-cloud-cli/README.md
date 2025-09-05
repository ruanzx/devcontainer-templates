# Google Cloud CLI DevContainer Feature

This feature installs [Google Cloud CLI](https://cloud.google.com/sdk/gcloud) (gcloud), the command-line interface for Google Cloud Platform services and resources.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of Google Cloud CLI to install. Use 'latest' for the most recent release or specify a version like '458.0.1' |
| `installGkeGcloudAuthPlugin` | boolean | `false` | Install the 'gke-gcloud-auth-plugin' for Kubernetes authentication |

## Examples

### Latest Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {}
    }
}
```

### Latest Version with GKE Authentication Plugin

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {
            "installGkeGcloudAuthPlugin": true
        }
    }
}
```

### Specific Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {
            "version": "458.0.1"
        }
    }
}
```

### Combined with Related Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {
            "installGkeGcloudAuthPlugin": true
        },
        "ghcr.io/devcontainers/features/docker-in-docker:latest": {},
        "ghcr.io/ruanzx/features/kubectl:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **Google Cloud CLI**: Core gcloud command-line tools
- **Default Components**:
  - `gcloud` - Core CLI commands
  - `gsutil` - Cloud Storage command-line tool
  - `bq` - BigQuery command-line tool
  - Alpha and Beta command groups
- **GKE Authentication Plugin** (optional): For Kubernetes cluster authentication

## Authentication

After installation, you'll need to authenticate with Google Cloud:

```bash
# Authenticate with your Google account
gcloud auth login

# Set your default project
gcloud config set project PROJECT_ID

# Verify authentication
gcloud auth list

# Check configuration
gcloud config list
```

## Verification

After installation, you can verify Google Cloud CLI is working:

```bash
# Check version
gcloud version

# List available components
gcloud components list

# Show current configuration
gcloud config list

# Test API access (requires authentication)
gcloud projects list
```

## Use Cases

### Cloud Development
- Deploy applications to Google Cloud Platform
- Manage cloud resources from the command line
- Automate cloud operations in CI/CD pipelines

### Kubernetes Development
- Manage Google Kubernetes Engine (GKE) clusters
- Deploy applications to Kubernetes
- Configure kubectl for cluster access

### Data and Analytics
- Work with BigQuery datasets and queries
- Manage Cloud Storage buckets and objects
- Process data with Cloud Functions and other services

### Infrastructure as Code
- Deploy resources using gcloud commands
- Manage infrastructure configurations
- Automate resource provisioning

## Common Commands

### Project and Configuration

```bash
# List available projects
gcloud projects list

# Set default project
gcloud config set project PROJECT_ID

# Set default region/zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Show current configuration
gcloud config list
```

### Compute Engine

```bash
# List VM instances
gcloud compute instances list

# Create a VM instance
gcloud compute instances create my-instance \
    --machine-type=e2-medium \
    --zone=us-central1-a

# SSH into an instance
gcloud compute ssh my-instance --zone=us-central1-a
```

### Google Kubernetes Engine (GKE)

```bash
# List GKE clusters
gcloud container clusters list

# Create a GKE cluster
gcloud container clusters create my-cluster \
    --zone=us-central1-a \
    --num-nodes=3

# Get cluster credentials for kubectl
gcloud container clusters get-credentials my-cluster --zone=us-central1-a
```

### Cloud Storage

```bash
# List buckets
gsutil ls

# Create a bucket
gsutil mb gs://my-bucket-name

# Copy files to/from bucket
gsutil cp file.txt gs://my-bucket-name/
gsutil cp gs://my-bucket-name/file.txt ./
```

### BigQuery

```bash
# List datasets
bq ls

# Run a query
bq query --use_legacy_sql=false "SELECT * FROM dataset.table LIMIT 10"

# Load data into BigQuery
bq load dataset.table data.csv schema.json
```

## Integration Examples

### CI/CD with GitHub Actions

```yaml
name: Deploy to Google Cloud
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
      - name: Deploy application
        run: |
          gcloud app deploy app.yaml --quiet
```

### Docker Multi-Stage Build

```dockerfile
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest AS gcloud
WORKDIR /app
COPY . .
RUN gcloud builds submit --tag gcr.io/PROJECT_ID/my-app

FROM node:18-alpine
COPY --from=gcloud /app/dist /app
EXPOSE 3000
CMD ["node", "server.js"]
```

### Infrastructure Automation

```bash
#!/bin/bash
# deploy-infrastructure.sh

# Set project and region
gcloud config set project my-project-id
gcloud config set compute/region us-central1

# Create VPC network
gcloud compute networks create my-vpc --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create my-subnet \
    --network=my-vpc \
    --range=10.0.0.0/24 \
    --region=us-central1

# Create GKE cluster
gcloud container clusters create my-cluster \
    --network=my-vpc \
    --subnetwork=my-subnet \
    --num-nodes=3
```

## Troubleshooting

### Authentication Issues

If you encounter authentication problems:

```bash
# Clear existing credentials
gcloud auth revoke --all

# Re-authenticate
gcloud auth login

# For service accounts
gcloud auth activate-service-account --key-file=path/to/key.json
```

### Project Configuration

If commands fail due to project issues:

```bash
# List available projects
gcloud projects list

# Set correct project
gcloud config set project PROJECT_ID

# Verify project settings
gcloud config get-value project
```

### Component Issues

If specific components are missing:

```bash
# List available components
gcloud components list

# Install missing components
gcloud components install COMPONENT_ID

# Update all components
gcloud components update
```

### Network and Firewall

For connectivity issues:

```bash
# Check firewall rules
gcloud compute firewall-rules list

# Create firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP"
```

### GKE Authentication Plugin

If you encounter kubectl authentication issues with GKE:

```bash
# Install the auth plugin
gcloud components install gke-gcloud-auth-plugin

# Update kubeconfig
gcloud container clusters get-credentials CLUSTER_NAME --zone=ZONE

# Test connection
kubectl get nodes
```

### Version Compatibility

If you need a specific version:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/google-cloud-cli:latest": {
            "version": "458.0.1"
        }
    }
}
```

## Platform Support

- ✅ Linux x86_64 (amd64)
- ✅ Linux ARM64 (aarch64)
- ❌ Windows (not supported)
- ❌ macOS (not supported)

## Related Features

- **Docker-in-Docker**: For building and deploying container images
- **kubectl**: For Kubernetes cluster management
- **Common Utils**: Required base utilities

## Security Considerations

- **Service Account Keys**: Store service account keys securely using secrets
- **IAM Permissions**: Follow principle of least privilege
- **Network Security**: Configure VPC networks and firewall rules appropriately
- **Resource Access**: Use IAM roles and policies to control resource access
- **Audit Logging**: Enable Cloud Audit Logs for compliance

## Environment Variables

Common environment variables for Google Cloud CLI:

- `GOOGLE_APPLICATION_CREDENTIALS`: Path to service account key file
- `GOOGLE_CLOUD_PROJECT`: Default project ID
- `CLOUDSDK_CORE_PROJECT`: Alternative way to set project
- `CLOUDSDK_COMPUTE_REGION`: Default region
- `CLOUDSDK_COMPUTE_ZONE`: Default zone

## Configuration Files

Google Cloud CLI stores configuration in:
- `~/.config/gcloud/` - Configuration directory
- `~/.config/gcloud/configurations/` - Named configurations
- `~/.config/gcloud/credentials/` - Authentication credentials

## Additional Resources

- [Google Cloud CLI Documentation](https://cloud.google.com/sdk/gcloud)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Cloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [Google Cloud Platform Quickstarts](https://cloud.google.com/docs/quickstarts)
- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Google Cloud IAM Documentation](https://cloud.google.com/iam/docs)
