
# Gitsign DevContainer Feature

This feature installs [Gitsign](https://github.com/sigstore/gitsign), a keyless Git signing tool that uses Sigstore for enhanced software supply chain security.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gitsign:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of Gitsign to install. Use 'latest' for the most recent release or specify a version like '0.12.0' |
| `configureGit` | boolean | `true` | Automatically configure git to use gitsign for commit and tag signing |

## Examples

### Latest Version with Git Configuration

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gitsign:latest": {}
    }
}
```

### Specific Version without Git Configuration

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gitsign:latest": {
            "version": "0.12.0",
            "configureGit": false
        }
    }
}
```

### Combined with Related Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gitsign:latest": {},
        "ghcr.io/ruanzx/features/cosign:latest": {},
        "ghcr.io/devcontainers/features/git:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **Gitsign CLI**: Keyless Git signing tool
- **Git configuration** (optional): Automatic setup to use gitsign for signing

## Git Configuration

When `configureGit` is `true` (default), the following git configuration is applied globally:

```bash
git config --global commit.gpgsign true      # Enable commit signing
git config --global tag.gpgsign true         # Enable tag signing  
git config --global gpg.x509.program gitsign # Use gitsign as GPG program
git config --global gpg.format x509          # Use x509 certificate format
```

## Verification

After installation, you can verify Gitsign is working:

```bash
# Check version
gitsign version

# Check git configuration
git config --global --list | grep -E "(gpg|sign)"

# Test signing (requires authentication)
echo "test" | gitsign sign

# Create a signed commit (will prompt for authentication)
git commit -S -m "Signed commit"
```

## Use Cases

### Software Supply Chain Security
- Sign Git commits without managing private keys
- Improve transparency and accountability in development
- Integrate with Sigstore ecosystem for comprehensive security

### Compliance and Governance
- Meet regulatory requirements for code signing
- Implement organization-wide signing policies
- Audit trail for all code changes

### DevSecOps Integration
- Automate commit signing in CI/CD pipelines
- Enforce signing policies across development teams
- Integrate with OIDC providers for seamless authentication

## Authentication

Gitsign uses keyless signing through Sigstore's infrastructure:

1. **OIDC Authentication**: Uses OpenID Connect providers (GitHub, Google, etc.)
2. **Fulcio Certificate Authority**: Issues short-lived certificates
3. **Rekor Transparency Log**: Records signatures for transparency

### Supported OIDC Providers
- GitHub
- Google
- Microsoft
- GitLab
- Custom OIDC providers

## Common Commands

```bash
# Check gitsign version and configuration
gitsign version

# Initialize gitsign (interactive setup)
gitsign initialize

# Sign a file manually
gitsign sign file.txt

# Verify a signature
gitsign verify file.txt.sig

# Create signed commit (automatic with git config)
git commit -S -m "Signed commit message"

# Create signed tag
git tag -s v1.0.0 -m "Signed tag"

# Verify commit signatures
git log --show-signature

# Verify tag signatures
git tag -v v1.0.0
```

## Integration Examples

### GitHub Actions Workflow

```yaml
name: Signed Commits
on: [push, pull_request]

jobs:
  sign-commits:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Install gitsign
        run: |
          curl -LO https://github.com/sigstore/gitsign/releases/latest/download/gitsign_linux_amd64
          sudo install gitsign_linux_amd64 /usr/local/bin/gitsign
      - name: Configure git
        run: |
          git config --global commit.gpgsign true
          git config --global tag.gpgsign true
          git config --global gpg.x509.program gitsign
          git config --global gpg.format x509
      - name: Make signed commit
        run: |
          git commit -S -m "Automated signed commit"
```

### Manual Configuration

```bash
# Configure git to use gitsign
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.x509.program gitsign
git config --global gpg.format x509

# Optional: Configure gitsign behavior
git config --global gitsign.fulcio https://fulcio.sigstore.dev
git config --global gitsign.rekor https://rekor.sigstore.dev
git config --global gitsign.issuer https://oauth2.sigstore.dev/auth
```

### Repository-Specific Configuration

```bash
# Configure for a specific repository
cd your-repo
git config commit.gpgsign true
git config tag.gpgsign true
git config gpg.x509.program gitsign
git config gpg.format x509
```

## Troubleshooting

### Authentication Issues

If you encounter authentication problems:

```bash
# Check gitsign configuration
gitsign version

# Clear any cached credentials
rm -rf ~/.gitsign

# Test authentication manually
echo "test" | gitsign sign
```

### OIDC Provider Issues

For OIDC authentication problems:

```bash
# Configure specific OIDC issuer
git config --global gitsign.issuer https://github.com/login/oauth

# Configure client ID
git config --global gitsign.clientid sigstore

# Enable debug logging
export GITSIGN_LOG=/tmp/gitsign.log
```

### Commit Signing Failures

If commits fail to sign:

```bash
# Check git configuration
git config --list | grep -E "(gpg|sign)"

# Test gitsign directly
echo "test" | gitsign sign

# Check for required environment variables
env | grep -i sign
```

### Certificate Issues

For certificate-related problems:

```bash
# Update CA certificates
sudo apt-get update && sudo apt-get install ca-certificates

# Check Fulcio connectivity
curl -v https://fulcio.sigstore.dev

# Check Rekor connectivity  
curl -v https://rekor.sigstore.dev
```

### Version Compatibility

If you need a specific version:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gitsign:latest": {
            "version": "0.12.0"
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

- **Cosign**: For container signing and verification
- **Git**: Version control system for signed commits
- **Common Utils**: Required base utilities

## Security Considerations

- **Keyless signing**: No private key management required
- **Certificate transparency**: All signatures logged in Rekor
- **OIDC authentication**: Leverages existing identity providers
- **Short-lived certificates**: Certificates expire quickly for security
- **Audit trail**: Complete transparency log of all signatures

## Environment Variables

Gitsign can be configured using environment variables:

- `GITSIGN_FULCIO_URL`: Fulcio CA URL (default: https://fulcio.sigstore.dev)
- `GITSIGN_REKOR_URL`: Rekor transparency log URL (default: https://rekor.sigstore.dev)
- `GITSIGN_OIDC_ISSUER`: OIDC issuer URL
- `GITSIGN_OIDC_CLIENT_ID`: OIDC client ID
- `GITSIGN_LOG`: Path to log file for debugging

## Additional Resources

- [Gitsign Documentation](https://docs.sigstore.dev/gitsign/overview/)
- [Sigstore Project](https://www.sigstore.dev/)
- [Keyless Signing Guide](https://docs.sigstore.dev/gitsign/keyless/)
- [Git Signing Documentation](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [OIDC Authentication](https://docs.sigstore.dev/gitsign/oidc/)
- [Fulcio Certificate Authority](https://docs.sigstore.dev/fulcio/overview/)
- [Rekor Transparency Log](https://docs.sigstore.dev/rekor/overview/)


