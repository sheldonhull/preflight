# preflight

Reusable Prek hooks and configurations to reduce copy-pasta across projects.

Prek is a Rust-based tool that improves the pre-commit experience with fast execution, TTY detection for VS Code compatibility, and automatic staging of fixed files.

## Remote Hook Configs

This repository provides **remote prek configurations** that can be shared across multiple repositories without duplicating configuration files.

### Available Configurations

#### Markdown Linting with Docker

Docker-based markdown linting with `markdownlint-cli2` and the `sentences-per-line` plugin.

**Features:**

- Containerized linting (consistent across all environments)
- Auto-fixes markdown on commit
- Validates markdown on push
- Better Git diffs with sentences-per-line rule
- Auto-stages fixed files (no extra manual step)
- VS Code compatible (TTY detection, stderr suppression)

**Quick Start:**

Add this to your repository's `prek.toml`:

```toml
[settings]
colors = "auto"
verbose = false

[settings.tty]
detect = true
suppress_stderr_when_no_tty = true
quiet_when_no_tty = true

[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "main"
config = "prek-markdown.toml"
```

Then run:

```bash
prek install
```

Done! Your repository now has automatic markdown linting.

**Documentation:**

- [Full Documentation](./MARKDOWN_LINTING.md) - Complete setup and usage guide
- [Quick Reference](./REMOTE_CONFIG_USAGE.md) - TL;DR for consumers
- [Example Configuration](./examples/remote-markdown-linting/) - Sample setup

#### Security Scanning with Docker

Docker-based security scanning with Checkov, Trivy, and Trufflehog.

**Features:**

- Infrastructure as Code security scanning (Checkov)
- Vulnerability and misconfiguration scanning (Trivy)
- Secrets detection (Trufflehog)
- All tools containerized
- VS Code compatible

**Quick Start:**

Add this to your repository's `prek.toml`:

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

Then run:

```bash
prek install
```

**Documentation:**

- [Full Documentation](./SECURITY_SCANNING.md) - Complete setup and usage guide
- [Quick Start](./SECURITY_SCANNING_QUICKSTART.md) - Get started in 3 steps
- [Example Configuration](./examples/remote-security-scanning/) - Sample setup

## What's Inside

- **Docker-based markdown linting** - Consistent linting across all repos
- **Docker-based security scanning** - Checkov, Trivy, and Trufflehog
- **Remote configurations** - Share hooks without config duplication
- **TTY detection** - VS Code compatibility with stderr suppression
- **Auto-staging** - Fixed files are automatically staged
- **Automated testing** - Verify your setup works
- **CI/CD workflows** - Build and publish Docker images
- **Fast Python installs** - Uses `uv` for package management

## For Maintainers

### Building the Docker Images

```bash
# Build markdown linting image
./build-markdownlint-image.sh

# Build security scanner images
./build-security-images.sh
```

### Running Tests

```bash
# Test markdown linting
./test-markdown-linting.sh

# Test security scanning
./test-security-scanning.sh
```

### Publishing to GHCR

The Docker images are automatically built and published via GitHub Actions on release.

## VS Code Compatibility

This configuration includes special handling for VS Code's Git integration:

- **TTY Detection**: Detects when running in non-interactive mode
- **Stderr Suppression**: Suppresses stderr output that causes VS Code to fail commits
- **Auto-staging**: Fixed files are automatically staged so commits work without extra steps
- **Skip Environment Variable**: Set `PREK_SKIP=1` to bypass all hooks

## Learn More

- [Prek Documentation](https://github.com/prek-dev/prek)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [Checkov](https://www.checkov.io/)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Trufflehog](https://github.com/trufflesecurity/trufflehog)
