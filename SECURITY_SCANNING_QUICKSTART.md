# Security Scanning - Quick Start

Get started with security scanning in 3 steps.

## 1. Add Remote Configuration

Add to your `prek.toml`:

```toml
[settings]
colors = "auto"
verbose = false

[settings.tty]
detect = true
suppress_stderr_when_no_tty = true
quiet_when_no_tty = true

[remotes.security]
url = "https://github.com/sheldonhull/preflight"
ref = "main"
config = "prek-security.toml"
```

## 2. Install Hooks

```bash
prek install
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

Security scanners run automatically!
They check for:

- Infrastructure security issues (Checkov)
- Vulnerabilities and misconfigurations (Trivy)
- Exposed secrets (Trufflehog)

## What Happens Next?

### No Issues Found

```
✓ checkov-scan
✓ trivy-fs-scan
✓ trufflehog-scan
[main abc1234] Your changes
```

Your commit succeeds!

### Issues Found

```
✗ checkov-scan
  Found 3 security issues in terraform files

✗ trufflehog-scan
  Found potential secret in config.py
```

Your commit is blocked.
Fix the issues and try again.

## Skipping Scans

When you need to bypass (use sparingly):

```bash
# Skip all hooks for one commit
git commit --no-verify -m "Emergency fix"

# Skip all prek hooks
PREK_SKIP=1 git commit -m "Skip all hooks"
```

## Customization

Create these files in your repo to customize (all optional):

- `.checkov.yaml` - Checkov settings
- `.trivy.yaml` - Trivy settings
- `.trufflehog.yaml` - Trufflehog settings

## VS Code Compatibility

This configuration includes special handling for VS Code:

- **TTY Detection**: Detects non-interactive mode automatically
- **Stderr Suppression**: Suppresses output that causes VS Code to fail commits
- **Skip Variable**: Set `PREK_SKIP=1` to bypass hooks entirely

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

## Python Package Management

The security scanner Docker images use `uv` for fast Python package installation.
This speeds up image builds while maintaining full compatibility with the tools.
