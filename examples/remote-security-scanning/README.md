# Remote Security Scanning Example

This example demonstrates how to consume the remote security scanning configuration from the preflight repository.

## Setup

1. Copy the `lefthook.yml` file to your repository root:
   ```bash
   cp lefthook.yml /path/to/your/repo/lefthook.yml
   ```

2. Install lefthook in your repository:
   ```bash
   cd /path/to/your/repo
   lefthook install
   ```

3. That's it! Security scanning is now enabled.

## What Gets Scanned

The remote configuration sets up three security scanners:

### Checkov
Scans Infrastructure as Code files for security issues:
- Terraform files (`.tf`)
- CloudFormation templates
- Kubernetes manifests
- Dockerfiles
- CI/CD configurations

### Trivy
Comprehensive security scanner that detects:
- Known vulnerabilities
- Misconfigurations
- Security best practice violations

### Trufflehog
Scans for exposed secrets:
- API keys
- Passwords
- Tokens
- Private keys
- Database credentials

## Testing

Try committing the sample files in this directory:

```bash
# This should pass (secure Terraform)
git add secure-example.tf
git commit -m "Add secure infrastructure"

# This should fail (insecure Terraform)
git add insecure-example.tf
git commit -m "Add insecure infrastructure"  # Will be blocked!
```

## Customization

### Override Default Configuration

Create these files in your repository root to customize scanner behavior:

- `.checkov.yaml` - Checkov configuration
- `.trivy.yaml` - Trivy configuration
- `.trufflehog.yaml` - Trufflehog configuration

Example `.checkov.yaml`:
```yaml
skip-check:
  - CKV_AWS_1  # Skip specific checks
  - CKV_AWS_2

framework:
  - terraform
  - dockerfile
```

### Disable Specific Scanners

Modify your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main
    configs:
      - lefthook-security.yml

# Disable specific scanners
pre-commit:
  commands:
    trufflehog-scan:
      skip: true  # Disable Trufflehog if not needed
```

### Run Only on Pre-Push

If pre-commit scans are too slow, run them only on pre-push:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main
    configs:
      - lefthook-security.yml

# Skip pre-commit scans
pre-commit:
  skip: true

# Only run on pre-push (keeps pre-push hooks active)
```

## Troubleshooting

### Docker Images Not Found

Manually pull the images:
```bash
docker pull ghcr.io/sheldonhull/lefthook/checkov:latest
docker pull ghcr.io/sheldonhull/lefthook/trivy:latest
docker pull ghcr.io/sheldonhull/lefthook/trufflehog:latest
```

### Hooks Not Running

Reinstall:
```bash
lefthook install
```

### Need to Skip Temporarily

```bash
git commit --no-verify -m "Skip hooks for this commit"
```

## Sample Files

This directory includes sample files for testing:

- `secure-example.tf` - Example of secure Terraform configuration
- `insecure-example.tf` - Example of insecure configuration (will trigger Checkov)
- `.checkov.yaml.example` - Example Checkov configuration
- `.trivy.yaml.example` - Example Trivy configuration
- `.trufflehog.yaml.example` - Example Trufflehog configuration

## More Information

See the main documentation:
- [SECURITY_SCANNING.md](../../SECURITY_SCANNING.md) - Comprehensive guide
- [SECURITY_SCANNING_QUICKSTART.md](../../SECURITY_SCANNING_QUICKSTART.md) - Quick start guide
