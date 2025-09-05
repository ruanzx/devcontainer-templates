
# Cosign DevContainer Feature

This feature installs [Cosign](https://github.com/sigstore/cosign), a tool for container signing verification and signing that's part of the Sigstore project.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/cosign:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of Cosign to install. Use 'latest' for the most recent release or specify a version like '2.4.0' |

## Examples

### Latest Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/cosign:latest": {}
    }
}
```

### Specific Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/cosign:latest": {
            "version": "2.4.0"
        }
    }
}
```

### Combined with Related Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/cosign:latest": {},
        "ghcr.io/devcontainers/features/docker-in-docker:latest": {},
        "ghcr.io/ruanzx/features/trivy:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **Cosign CLI**: Container signing verification and signing tool

## Environment Variables

The feature sets:
- `COSIGN_YES=true`: Automatically accept Cosign prompts for non-interactive usage

## Verification

After installation, you can verify Cosign is working:

```bash
# Check version
cosign version

# Generate a key pair (example)
cosign generate-key-pair

# Sign a container image (example)
cosign sign --key cosign.key <image>

# Verify a signed image (example)
cosign verify --key cosign.pub <image>
```

## Use Cases

### Container Security
- Sign container images to ensure integrity
- Verify signatures before deployment
- Implement supply chain security policies

### Software Supply Chain Security
- Sign and verify software artifacts
- Integrate with CI/CD pipelines for automated signing
- Comply with software bill of materials (SBOM) requirements

### DevSecOps Integration
- Automate container signing in development workflows
- Verify dependencies and base images
- Implement security gates in deployment pipelines

## Common Commands

```bash
# Generate a key pair
cosign generate-key-pair

# Sign a container image
cosign sign --key cosign.key registry/image:tag

# Verify a signed image
cosign verify --key cosign.pub registry/image:tag

# Sign with keyless mode (using OIDC)
cosign sign registry/image:tag

# Verify keyless signature
cosign verify --certificate-identity user@domain.com \
  --certificate-oidc-issuer https://github.com/login/oauth \
  registry/image:tag

# Generate SBOM attestation
cosign attest --predicate sbom.json --key cosign.key registry/image:tag

# Verify attestation
cosign verify-attestation --key cosign.pub registry/image:tag
```

## Integration Examples

### With GitHub Actions

```yaml
- name: Sign container image
  run: |
    cosign sign --key env://COSIGN_PRIVATE_KEY ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
  env:
    COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
    COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
```

### With Docker Compose

```yaml
version: '3.8'
services:
  app:
    image: myregistry/myapp:latest
    # Image should be signed with Cosign
```

### Policy Enforcement

```bash
# Create admission controller policy
cosign policy init --type cue policy.cue

# Apply policy to verify all images
kubectl apply -f cosign-policy.yaml
```

## Troubleshooting

### Permission Issues
If you encounter permission issues:

```bash
# Ensure proper file permissions
chmod 600 cosign.key
chmod 644 cosign.pub
```

### Registry Authentication
For private registries:

```bash
# Login to registry first
docker login myregistry.com

# Then sign/verify images
cosign sign --key cosign.key myregistry.com/image:tag
```

### Keyless Signing Issues
For keyless signing problems:

```bash
# Ensure OIDC provider is accessible
cosign sign --experimental=1 registry/image:tag

# Check certificate transparency log
cosign verify --experimental=1 registry/image:tag
```

### Version Compatibility
If you need a specific version:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/cosign:latest": {
            "version": "2.4.0"
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

- **Docker-in-Docker**: For building and testing container images
- **Trivy**: For container vulnerability scanning
- **kubectl**: For Kubernetes deployments with signed images

## Security Considerations

- Store private keys securely using secrets management
- Use keyless signing when possible for better security
- Implement admission controllers to enforce signature verification
- Regularly rotate signing keys
- Monitor certificate transparency logs

## Additional Resources

- [Cosign Documentation](https://docs.sigstore.dev/cosign/overview/)
- [Sigstore Project](https://www.sigstore.dev/)
- [Container Signing Best Practices](https://docs.sigstore.dev/cosign/best-practices/)
- [Keyless Signing Guide](https://docs.sigstore.dev/cosign/keyless/)


