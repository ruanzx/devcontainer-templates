# kubeseal DevContainer Feature

This feature installs [kubeseal](https://github.com/bitnami-labs/sealed-secrets), the client-side utility for Kubernetes Sealed Secrets. Sealed Secrets provide a way to encrypt your Kubernetes secrets into SealedSecret custom resources, which can be safely stored in version control.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of kubeseal to install. Use 'latest' for the most recent release or specify a version like '0.24.0' |
| `sha256` | string | `"automatic"` | SHA256 checksum for verification. Use 'automatic' to download checksums, 'dev-mode' to skip verification, or provide a specific checksum |

## Examples

### Latest Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {}
    }
}
```

### Specific Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {
            "version": "v0.30.0"
        }
    }
}
```

### With Custom Checksum

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {
            "version": "v0.30.0",
            "sha256": "dev-mode"
        }
    }
}
```

### Combined with Kubernetes Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {},
        "ghcr.io/ruanzx/features/kubectl:latest": {},
        "ghcr.io/ruanzx/features/helm:latest": {},
        "ghcr.io/devcontainers/features/docker-in-docker:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **kubeseal CLI**: Client-side utility for creating and managing Sealed Secrets

## Prerequisites

To use kubeseal effectively, you need:
- A Kubernetes cluster with the Sealed Secrets controller installed
- kubectl configured to access your cluster
- Appropriate RBAC permissions to create/read secrets and sealed secrets

## Verification

After installation, you can verify kubeseal is working:

```bash
# Check version
kubeseal --version

# Get help
kubeseal --help

# Fetch the public key from the cluster (requires kubectl access)
kubeseal --fetch-cert --controller-name sealed-secrets-controller --controller-namespace sealed-secrets

# Create a sealed secret from a secret file
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

## Use Cases

### Secure Secret Management
- Store encrypted secrets in version control safely
- Automate secret deployment without exposing sensitive data
- Implement GitOps workflows with encrypted secrets

### CI/CD Integration
- Encrypt secrets in CI/CD pipelines
- Deploy applications with secrets securely
- Manage environment-specific secret configurations

### Development Workflows
- Share encrypted secrets safely among team members
- Test applications with realistic secret configurations
- Maintain secret consistency across environments

## Common Commands

### Basic Operations

```bash
# Fetch the public certificate from the cluster
kubeseal --fetch-cert > public.pem

# Create a sealed secret from a Kubernetes secret
echo -n mypassword | kubectl create secret generic mysecret --dry-run=client --from-file=password=/dev/stdin -o yaml | kubeseal -o yaml > mysealedsecret.yaml

# Create a sealed secret from literal values
echo -n mypassword | kubectl create secret generic mysecret --dry-run=client --from-literal=password=/dev/stdin -o yaml | kubeseal -o yaml > mysealedsecret.yaml

# Seal an existing secret file
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

### Advanced Usage

```bash
# Use a specific scope (strict, namespace-wide, cluster-wide)
kubeseal --scope strict --format yaml < secret.yaml > sealed-secret.yaml

# Encrypt raw values directly
echo -n mypassword | kubeseal --raw --from-file=/dev/stdin --name mysecret --namespace mynamespace

# Use offline mode with a saved certificate
kubeseal --cert public.pem --format yaml < secret.yaml > sealed-secret.yaml

# Specify controller details
kubeseal --controller-name sealed-secrets --controller-namespace kube-system --format yaml < secret.yaml > sealed-secret.yaml
```

### Certificate Management

```bash
# Fetch certificate from specific controller
kubeseal --fetch-cert --controller-name sealed-secrets-controller --controller-namespace sealed-secrets > public.pem

# Fetch certificate with custom context/cluster
kubeseal --fetch-cert --context my-context > public.pem

# Validate certificate
kubeseal --validate --cert public.pem
```

### Output Formats

```bash
# YAML output (default)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml

# JSON output
kubeseal --format json < secret.yaml > sealed-secret.json

# Raw encrypted value
echo -n mypassword | kubeseal --raw --from-file=/dev/stdin --name mysecret --namespace mynamespace
```

## Secret Scopes

Sealed Secrets support different encryption scopes:

### Strict (default)
```bash
# Secret can only be decrypted by a secret with the same name and namespace
kubeseal --scope strict --format yaml < secret.yaml > sealed-secret.yaml
```

### Namespace-wide
```bash
# Secret can be decrypted by any secret in the same namespace
kubeseal --scope namespace-wide --format yaml < secret.yaml > sealed-secret.yaml
```

### Cluster-wide
```bash
# Secret can be decrypted by any secret in the cluster
kubeseal --scope cluster-wide --format yaml < secret.yaml > sealed-secret.yaml
```

## Integration Examples

### GitOps Workflow

```bash
#!/bin/bash
# encrypt-secrets.sh

# Create secret manifest
kubectl create secret generic app-secrets \
  --from-literal=database-password=supersecret \
  --from-literal=api-key=myapikey \
  --dry-run=client -o yaml > secret.yaml

# Encrypt the secret
kubeseal --format yaml < secret.yaml > sealed-secret.yaml

# Remove plain secret file
rm secret.yaml

# Commit encrypted secret to git
git add sealed-secret.yaml
git commit -m "Add encrypted application secrets"
git push
```

### GitHub Actions Workflow

```yaml
name: Seal Secrets
on:
  push:
    paths: ['secrets/*.yaml']

jobs:
  seal-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install kubeseal
        run: |
          curl -sSL https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64.tar.gz | tar xz
          sudo install kubeseal /usr/local/bin/
      
      - name: Configure kubectl
        run: |
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > kubeconfig
          export KUBECONFIG=kubeconfig
      
      - name: Seal secrets
        run: |
          for secret in secrets/*.yaml; do
            kubeseal --format yaml < "$secret" > "sealed-$(basename "$secret")"
          done
      
      - name: Commit sealed secrets
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add sealed-*.yaml
          git commit -m "Update sealed secrets" || exit 0
          git push
```

### Helm Integration

```yaml
# values.yaml
sealedSecrets:
  enabled: true
  secrets:
    - name: app-database
      encryptedData:
        password: AgAR7tB9... # Generated by kubeseal

# templates/sealed-secret.yaml
{{- if .Values.sealedSecrets.enabled }}
{{- range .Values.sealedSecrets.secrets }}
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{ .name }}
  namespace: {{ $.Release.Namespace }}
spec:
  encryptedData:
    {{- toYaml .encryptedData | nindent 4 }}
{{- end }}
{{- end }}
```

### Makefile Integration

```makefile
# Makefile
.PHONY: seal-secrets
seal-secrets:
	@echo "Sealing secrets..."
	@for secret in secrets/*.yaml; do \
		echo "Sealing $$secret"; \
		kubeseal --format yaml < "$$secret" > "sealed-$$(basename $$secret)"; \
	done
	@echo "Secrets sealed successfully"

.PHONY: fetch-cert
fetch-cert:
	@echo "Fetching sealed secrets certificate..."
	@kubeseal --fetch-cert > sealed-secrets.pem
	@echo "Certificate saved to sealed-secrets.pem"

.PHONY: validate-cert
validate-cert:
	@echo "Validating certificate..."
	@kubeseal --validate --cert sealed-secrets.pem
```

## Troubleshooting

### Controller Not Found

If kubeseal can't find the controller:

```bash
# Check if controller is running
kubectl get pods -n sealed-secrets

# Check controller with custom name/namespace
kubeseal --controller-name custom-sealed-secrets --controller-namespace kube-system --fetch-cert

# Use offline mode with saved certificate
kubeseal --cert public.pem --format yaml < secret.yaml > sealed-secret.yaml
```

### Certificate Issues

If certificate fetching fails:

```bash
# Check kubectl access
kubectl get nodes

# Verify controller is accessible
kubectl get service -n sealed-secrets

# Check RBAC permissions
kubectl auth can-i get secrets
kubectl auth can-i create sealedsecrets
```

### Encryption/Decryption Failures

If sealed secrets can't be decrypted:

```bash
# Check scope issues
kubeseal --scope namespace-wide --format yaml < secret.yaml > sealed-secret.yaml

# Verify namespace and name match
kubectl describe sealedsecret mysecret -n mynamespace

# Check controller logs
kubectl logs -n sealed-secrets deployment/sealed-secrets-controller
```

### Version Compatibility

Ensure kubeseal version compatibility:

```bash
# Check controller version
kubectl get deployment sealed-secrets-controller -n sealed-secrets -o jsonpath='{.spec.template.spec.containers[0].image}'

# Use compatible kubeseal version
# kubeseal v0.30.x is compatible with controller v0.30.x
```

### Network Issues

If download fails:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/kubeseal:latest": {
            "version": "v0.30.0",
            "sha256": "dev-mode"
        }
    }
}
```

## Platform Support

- ✅ Linux x86_64 (amd64)
- ✅ Linux ARM64 (aarch64)
- ✅ Linux ARM (armv7)
- ✅ Linux 386 (i386)
- ❌ Windows (not supported)
- ❌ macOS (not supported)

## Security Considerations

- **Certificate Management**: Protect the private key of the sealed-secrets controller
- **Scope Selection**: Use the most restrictive scope that meets your needs
- **Key Rotation**: Plan for periodic certificate rotation
- **Access Control**: Implement proper RBAC for sealed secrets resources
- **Backup Strategy**: Backup controller private keys securely

## Controller Installation

Before using kubeseal, install the Sealed Secrets controller in your cluster:

```bash
# Install using kubectl
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.31.0/controller.yaml

# Or install using Helm
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets -n sealed-secrets --create-namespace
```

## Related Features

- **kubectl**: Required for cluster access and secret management
- **Helm**: For installing the Sealed Secrets controller
- **Docker-in-Docker**: For building container images with secrets
- **Common Utils**: Required base utilities

## Best Practices

- **Use GitOps**: Store sealed secrets in version control
- **Automate Encryption**: Use CI/CD pipelines to encrypt secrets
- **Scope Appropriately**: Choose the right scope for your security needs
- **Monitor Controller**: Set up monitoring for the sealed secrets controller
- **Regular Updates**: Keep kubeseal and controller versions in sync

## Additional Resources

- [Sealed Secrets Documentation](https://github.com/bitnami-labs/sealed-secrets)
- [Sealed Secrets Controller](https://sealed-secrets.netlify.app/)
- [Kubernetes Secrets Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)
- [GitOps with Sealed Secrets](https://blog.gitguardian.com/sealed-secrets/)
- [Bitnami Sealed Secrets Helm Chart](https://github.com/bitnami-labs/sealed-secrets/tree/main/helm/sealed-secrets)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/)
