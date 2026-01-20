# preflight

Reusable Prek (pre-commit) hooks and configurations to reduce copy-pasta across projects.

Prek is compatible with the standard pre-commit YAML format and provides fast execution with cross-platform support.

## Quick Start

Copy `.pre-commit-config.yaml` to your repository and run:

```bash
prek install
```

Or with standard pre-commit:

```bash
pre-commit install
```

## Features

- **Cross-platform**: Uses `docker_image` language type (works on Windows/Mac/Linux)
- **VS Code compatible**: Output suppressed on success (`verbose: false` by default)
- **Auto-staging**: Fixed files are automatically re-staged via PowerShell Core
- **Staged hooks**: Pre-commit (fast), pre-push (thorough), manual (audit)

## Hook Stages

### Pre-commit (default)

Fast checks that run on every commit:

- `markdownlint` - Markdown linting with auto-fix
- `restage-formatted` - Re-stage files fixed by formatters
- `checkov` - Quick IaC security scan
- `trufflehog-quick` - Quick secrets scan

### Pre-push

Thorough validation before pushing:

- `checkov-full` - Full IaC security scan
- `trufflehog-full` - Full secrets scan from base branch
- `trivy-vulnerabilities` - Vulnerability scan
- `trivy-config` - Config/misconfiguration scan
- `markdownlint-check` - Markdown validation (no fix)

### Manual

Security audits (run with `prek run --hook-stage manual`):

- `audit-secrets` - Secrets audit (last 10 commits)
- `audit-checkov` - Full Checkov audit
- `audit-vulnerabilities` - Full vulnerability audit
- `audit-config` - Config misconfiguration audit

### Init

Pull Docker containers (run with `prek run --hook-stage manual -a init-`):

- `init-markdown` - Pull markdown linting containers
- `init-security` - Pull security scanning containers
- `init-all` - Pull all containers

## Usage

```bash
# Install git hooks
prek install

# Run all pre-commit hooks manually
prek run --all-files

# Run pre-push hooks
prek run --hook-stage pre-push

# Run manual audit hooks
prek run --hook-stage manual

# Pull all Docker images
prek run --hook-stage manual -a init-all

# Skip hooks for emergency commits
PREK_SKIP=1 git commit -m "emergency fix"
```

## What's Inside

- **Docker-based markdown linting** - markdownlint-cli2
- **Docker-based security scanning** - Checkov, Trivy, Trufflehog
- **Cross-platform hooks** - PowerShell Core for git operations
- **VS Code compatibility** - Proper output handling for IDE commits
- **Auto-staging** - Fixed files are automatically staged

## VS Code Compatibility

This configuration includes special handling for VS Code's Git integration:

- **Output suppression**: `verbose: false` (default) suppresses output on success
- **Error-only output**: Errors are still shown when hooks fail
- **Auto-staging**: Fixed files are automatically re-staged via PowerShell
- **Skip hooks**: Set `PREK_SKIP=1` to bypass all hooks for emergency commits

## For Maintainers

### Building Custom Docker Images

```bash
# Build markdown linting image (optional - uses public images by default)
./build-markdownlint-image.sh

# Build security scanner images (optional - uses public images by default)
./build-security-images.sh
```

### Running Tests

```bash
# Test markdown linting
./test-markdown-linting.sh

# Test security scanning
./test-security-scanning.sh
```

## Documentation

- [Markdown Linting Guide](./MARKDOWN_LINTING.md)
- [Security Scanning Guide](./SECURITY_SCANNING.md)
- [Security Scanning Quick Start](./SECURITY_SCANNING_QUICKSTART.md)
- [Remote Config Usage](./REMOTE_CONFIG_USAGE.md)

## Learn More

- [pre-commit](https://pre-commit.com/)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [Checkov](https://www.checkov.io/)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Trufflehog](https://github.com/trufflesecurity/trufflehog)
