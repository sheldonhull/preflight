# Security Scanning with Lefthook

This repository provides containerized security scanning tools that can be consumed as remote Lefthook configurations. The setup includes three powerful security scanners:

- **Checkov**: Infrastructure as Code (IaC) security scanner
- **Trivy**: Comprehensive vulnerability and misconfiguration scanner
- **Trufflehog**: Secrets scanner for detecting exposed credentials

## Quick Start

Add this to your repository's `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main  # or specific tag for stability
    configs:
      - lefthook-security.yml
```

Then run:

```bash
lefthook install
```

That's it! The security scanners will now run automatically:
- **Pre-commit**: Scans staged files for security issues
- **Pre-push**: Performs comprehensive security validation before pushing

## What Gets Scanned

### Checkov
- Terraform files (`.tf`)
- CloudFormation templates (`.yml`, `.yaml`, `.json`)
- Dockerfiles
- Kubernetes manifests
- GitHub Actions workflows
- Other IaC files

Checkov checks for:
- Security misconfigurations
- Compliance violations
- Best practice violations
- Resource policies

### Trivy
- Filesystem scanning for vulnerabilities
- Configuration files
- Infrastructure as Code
- Dockerfiles
- Kubernetes manifests

Trivy detects:
- Known vulnerabilities (CVEs)
- Misconfigurations
- Security issues
- Best practice violations

### Trufflehog
- All files in the repository
- Git history

Trufflehog finds:
- API keys
- Passwords
- Tokens
- Private keys
- Database credentials
- Other secrets

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Your Repository                                              │
│                                                              │
│  lefthook.yml (3 lines)                                     │
│      ↓                                                       │
│  References remote config from sheldonhull/preflight        │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Remote Configuration (lefthook-security.yml)                │
│                                                              │
│  Pre-commit Hooks:                                          │
│    - Checkov scan (IaC files)                               │
│    - Trivy filesystem scan                                  │
│    - Trufflehog secret scan                                 │
│                                                              │
│  Pre-push Hooks:                                            │
│    - Checkov validate (strict)                              │
│    - Trivy full scan (strict)                               │
│    - Trufflehog validate (strict)                           │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Docker Containers (ghcr.io/sheldonhull/lefthook/*)         │
│                                                              │
│  - checkov:latest                                           │
│  - trivy:latest                                             │
│  - trufflehog:latest                                        │
│                                                              │
│  Pulled automatically during `lefthook install`             │
└──────────────────────────────────────────────────────────────┘
```

### Workflow

1. **Developer commits code**
   ```bash
   git add .
   git commit -m "Add new feature"
   ```

2. **Pre-commit hooks run automatically**
   - Checkov scans IaC files for security issues
   - Trivy scans filesystem for vulnerabilities
   - Trufflehog scans for exposed secrets

3. **If issues found**
   - Commit is blocked
   - Issues are displayed in terminal
   - Developer fixes issues and retries

4. **Developer pushes code**
   ```bash
   git push
   ```

5. **Pre-push hooks run automatically**
   - Comprehensive security validation
   - Stricter checks than pre-commit
   - Ensures no security issues reach remote

## Configuration

### Default Configuration

The scanners come with sensible defaults:

- **Skip common directories**: `.git`, `node_modules`, `.terraform`, `vendor`, etc.
- **Report critical and high severity issues**
- **Fail on security findings** (configurable)

### Customizing for Your Repository

Create local configuration files to override defaults:

#### `.checkov.yaml` (optional)
```yaml
# Add your repository-specific Checkov settings
skip-check:
  - CKV_AWS_1  # Skip specific checks

framework:
  - terraform
  - dockerfile
  - kubernetes
```

#### `.trivy.yaml` (optional)
```yaml
# Add your repository-specific Trivy settings
severity:
  - CRITICAL
  - HIGH

scan:
  skip-dirs:
    - custom-dir-to-skip
```

#### `.trufflehog.yaml` (optional)
```yaml
# Add your repository-specific Trufflehog settings
exclude_patterns:
  - "test.*secret"
  - "dummy.*key"

entropy:
  min_entropy_hex: 4.0
```

### Disabling Specific Scanners

If you only want some scanners, create your own `lefthook.yml`:

```yaml
# Use only Checkov and Trivy (skip Trufflehog)
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main

pre-commit:
  commands:
    checkov-scan:
      glob: "*.{tf,yml,yaml,json,dockerfile,Dockerfile}"
      run: docker run --rm -v "$(pwd):/workspace" -w /workspace ghcr.io/sheldonhull/lefthook/checkov:latest checkov --directory /workspace

    trivy-fs-scan:
      run: docker run --rm -v "$(pwd):/workspace" -w /workspace ghcr.io/sheldonhull/lefthook/trivy:latest trivy fs --exit-code 0 .
```

## Skipping Hooks

Sometimes you need to skip security checks:

### Skip all hooks for one commit
```bash
git commit --no-verify -m "Emergency hotfix"
```

### Skip all hooks temporarily
```bash
LEFTHOOK=0 git commit -m "Skip hooks"
```

### Skip specific hook
```bash
LEFTHOOK_EXCLUDE=checkov-scan git commit -m "Skip only Checkov"
```

## CI/CD Integration

The security scanners can also run in CI/CD:

```yaml
# .github/workflows/security-scan.yml
name: Security Scanning

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Checkov
        run: |
          docker run --rm -v "$PWD:/workspace" -w /workspace \
            ghcr.io/sheldonhull/lefthook/checkov:latest \
            checkov --directory /workspace

      - name: Run Trivy
        run: |
          docker run --rm -v "$PWD:/workspace" -w /workspace \
            ghcr.io/sheldonhull/lefthook/trivy:latest \
            trivy fs .

      - name: Run Trufflehog
        run: |
          docker run --rm -v "$PWD:/workspace" -v "$PWD/.git:/workspace/.git" \
            -w /workspace \
            ghcr.io/sheldonhull/lefthook/trufflehog:latest \
            trufflehog --regex --entropy=True /workspace
```

## Troubleshooting

### Docker image not found
```bash
# Manually pull the images
docker pull ghcr.io/sheldonhull/lefthook/checkov:latest
docker pull ghcr.io/sheldonhull/lefthook/trivy:latest
docker pull ghcr.io/sheldonhull/lefthook/trufflehog:latest
```

### Hooks not running
```bash
# Reinstall hooks
lefthook install

# Check configuration
lefthook run --help
```

### Too many false positives

Create local configuration files (`.checkov.yaml`, `.trivy.yaml`, `.trufflehog.yaml`) to suppress specific findings:

```yaml
# .checkov.yaml
skip-check:
  - CKV_AWS_1
  - CKV_AWS_2
```

### Performance issues

For large repositories, you may want to:

1. Limit scanning to specific directories
2. Use `.dockerignore` to exclude unnecessary files
3. Run scanners only on pre-push (not pre-commit)

```yaml
# lefthook.yml - Only run on pre-push
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main

pre-commit:
  skip: true  # Skip security scans on pre-commit

pre-push:
  commands:
    security-scan:
      run: ./run-security-scans.sh
```

## Security Best Practices

1. **Pin versions**: Use specific tags instead of `latest` for production
   ```yaml
   remotes:
     - git_url: https://github.com/sheldonhull/preflight
       ref: v1.0.0  # Use specific version
   ```

2. **Review findings**: Don't blindly suppress security warnings
3. **Keep scanners updated**: Regularly update to get latest vulnerability data
4. **Use in CI/CD**: Run scanners in your CI/CD pipeline as well
5. **Educate team**: Ensure team understands security findings

## Examples

See the `examples/security-scanning/` directory for complete working examples of consuming repositories.

## Testing

Test the scanners locally:

```bash
# Run all tests
./test-security-scanning.sh

# Build images locally
./build-security-images.sh

# Test specific scanner
docker run --rm ghcr.io/sheldonhull/lefthook/checkov:latest checkov --version
docker run --rm ghcr.io/sheldonhull/lefthook/trivy:latest trivy --version
docker run --rm ghcr.io/sheldonhull/lefthook/trufflehog:latest trufflehog --help
```

## Support

- **Issues**: Report issues at https://github.com/sheldonhull/preflight/issues
- **Documentation**: See this file and `REMOTE_CONFIG_USAGE.md`
- **Test Cases**: See `test-cases/security-scanning/` for examples

## Version Information

- **Checkov**: 3.2.9
- **Trivy**: 0.55.2
- **Trufflehog**: 2.2.1

These versions are pinned in the Dockerfiles for reproducibility. Updates will be released as new versions of this repository.
