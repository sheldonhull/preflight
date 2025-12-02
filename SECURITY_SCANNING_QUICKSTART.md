# Security Scanning - Quick Start

Get started with security scanning in 3 steps.

## 1. Add Remote Configuration

Add to your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main
    configs:
      - lefthook-security.yml
```

## 2. Install Hooks

```bash
lefthook install
```

This automatically:
- Pulls Docker images for Checkov, Trivy, and Trufflehog
- Sets up pre-commit and pre-push hooks
- Configures security scanning

## 3. Commit Your Code

```bash
git add .
git commit -m "Your changes"
```

Security scanners run automatically! They check for:
- Infrastructure security issues (Checkov)
- Vulnerabilities and misconfigurations (Trivy)
- Exposed secrets (Trufflehog)

## What Happens Next?

### ✅ No Issues Found
```
✓ checkov-scan
✓ trivy-fs-scan
✓ trufflehog-scan
[main abc1234] Your changes
```

Your commit succeeds!

### ❌ Issues Found
```
✗ checkov-scan
  Found 3 security issues in terraform files

✗ trufflehog-scan
  Found potential secret in config.py
```

Your commit is blocked. Fix the issues and try again.

## Skipping Scans

When you need to bypass (use sparingly):

```bash
# Skip all hooks for one commit
git commit --no-verify -m "Emergency fix"

# Skip specific scanner
LEFTHOOK_EXCLUDE=checkov-scan git commit -m "Skip Checkov"
```

## Customization

Create these files in your repo to customize (all optional):

- `.checkov.yaml` - Checkov settings
- `.trivy.yaml` - Trivy settings
- `.trufflehog.yaml` - Trufflehog settings

## Need Help?

See [SECURITY_SCANNING.md](./SECURITY_SCANNING.md) for:
- Detailed configuration options
- Troubleshooting guide
- CI/CD integration
- Security best practices

## Tools Included

| Tool | Purpose | Scans |
|------|---------|-------|
| **Checkov** | IaC Security | Terraform, CloudFormation, Kubernetes, Dockerfiles |
| **Trivy** | Vulnerability Scanner | Filesystem, configs, IaC, containers |
| **Trufflehog** | Secrets Detection | API keys, passwords, tokens, private keys |

All tools run in Docker containers - no local installation required!
