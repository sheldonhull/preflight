# Markdown Linting with Prek and Docker

This repository provides a **reusable, Docker-based markdown linting solution** that can be shared across multiple repositories without requiring each repo to maintain linting configuration files or Docker images.

## Features

- **Containerized**: Uses Docker to ensure consistent linting across all environments
- **Custom Plugin Support**: Includes the [sentences-per-line](https://github.com/JoshuaKGoldberg/sentences-per-line) plugin for better Git diffs
- **Remote Configuration**: Uses prek's remote config feature to share setup across repos
- **Auto-fix on Commit**: Automatically formats markdown files on `pre-commit`
- **Auto-staging**: Fixed files are automatically staged (no extra manual step!)
- **Validation on Push**: Validates markdown without auto-fix on `pre-push`
- **Pre-pulled Images**: The `install` hook pulls the Docker image so hook execution is fast
- **VS Code Compatible**: TTY detection and stderr suppression for non-interactive environments

## Quick Start for Other Repositories

### 1. Add Remote Configuration to Your Repo

In your repository, create or update `prek.toml`:

```toml
# prek.toml

[settings]
colors = "auto"
verbose = false

# TTY detection for VS Code compatibility
[settings.tty]
detect = true
suppress_stderr_when_no_tty = true
quiet_when_no_tty = true

# Pull markdown linting configuration from this repo
[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "main"  # or use a specific tag like v1.0.0 for stability
config = "prek-markdown.toml"
```

### 2. Install Prek

```bash
# If prek is not installed yet
cargo install prek
# or: brew install prek

# Initialize prek in your repo (this will also run the install hook)
prek install
```

That's it! The remote configuration will be automatically fetched, and the Docker image will be pulled during installation.

### 3. How It Works

- **On first install**: The Docker image is pulled (one-time setup)
- **On `git commit`**: Markdown files are automatically formatted with `--fix` and staged
- **On `git push`**: Markdown files are validated (without auto-fix)

## For This Repository (Setup & Maintenance)

### Building the Docker Image

```bash
# Build the image locally
./build-markdownlint-image.sh

# Test the image
docker run --rm preflight/markdownlint-cli2:latest markdownlint-cli2 --version
```

### Publishing to a Container Registry

For other repositories to use this without building, publish the image to a registry:

#### GitHub Container Registry (GHCR)

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Tag the image
docker tag preflight/markdownlint-cli2:latest ghcr.io/sheldonhull/markdownlint-cli2:latest

# Push to registry
docker push ghcr.io/sheldonhull/markdownlint-cli2:latest
```

Then update `prek-markdown.toml` to reference `ghcr.io/sheldonhull/markdownlint-cli2:latest` instead of `preflight/markdownlint-cli2:latest`.

#### Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag the image
docker tag preflight/markdownlint-cli2:latest YOUR_USERNAME/markdownlint-cli2:latest

# Push to registry
docker push YOUR_USERNAME/markdownlint-cli2:latest
```

### Testing Locally

```bash
# Install prek in this repo
prek install

# Test the install hook (pulls Docker image)
prek run install

# Test pre-commit formatting (auto-stages fixed files!)
prek run pre-commit

# Test pre-push validation
prek run pre-push

# Or test on specific files
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  preflight/markdownlint-cli2:latest \
  markdownlint-cli2 "README.md"
```

## Configuration Files

### `Dockerfile.markdownlint`

The Dockerfile that builds the linting image with:

- Node.js 20 Alpine (small footprint)
- markdownlint-cli2 (latest version)
- sentences-per-line plugin

### `prek-markdown.toml`

The remote prek configuration that defines:

- **install hook**: Pulls the Docker image
- **pre-commit hook**: Auto-formats markdown files and stages them
- **pre-push hook**: Validates markdown files

### `.markdownlint-cli2.yaml`

Primary configuration for markdownlint-cli2 with:

- Custom rules (sentences-per-line)
- Rule configuration
- File globs and ignore patterns

### `.markdownlint.yaml`

Fallback configuration for local editors/IDEs (without custom plugins).

## Customizing for Your Needs

### Override Rules in Other Repos

If a consuming repository needs different rules, they can create their own `.markdownlint-cli2.yaml` file locally.
The local configuration will take precedence.

### Skip Linting for Specific Commits

```bash
# Skip all prek hooks
PREK_SKIP=1 git commit -m "docs: emergency fix"

# Skip using git's built-in mechanism
git commit --no-verify -m "docs: skip linting"
```

### Disable Specific Hooks

Create `prek-local.toml` in your repo (add to `.gitignore`):

```toml
# prek-local.toml

[hooks.pre-commit.commands.markdownlint-fmt]
skip = true
```

## Architecture Decisions

### Why Docker?

- **Consistency**: Same linting environment across all machines and CI/CD
- **No Local Dependencies**: Don't need Node.js, npm, or packages installed locally
- **Version Control**: Lock specific versions of tools and plugins
- **Isolation**: No conflicts with project dependencies

### Why Prek Remote Configs?

- **DRY Principle**: Define configuration once, use everywhere
- **Centralized Updates**: Update linting rules in one place
- **No Config Sprawl**: Other repos don't need to maintain config files
- **Easy Adoption**: New repos add a few lines to their `prek.toml`

### Why sentences-per-line Plugin?

- **Better Git Diffs**: One sentence per line means cleaner, more readable diffs
- **Easier Reviews**: Changes to specific sentences are isolated
- **Conflict Reduction**: Fewer merge conflicts in documentation

### Why Auto-staging?

- **VS Code Compatibility**: VS Code commits work without requiring extra steps
- **Better UX**: Developers don't need to remember to stage fixed files
- **Atomic Commits**: Formatting fixes are included in the same commit

## Troubleshooting

### Docker image not found

If you see "docker: image not found", build or pull the image:

```bash
# Build locally
./build-markdownlint-image.sh

# Or if published to a registry
docker pull ghcr.io/sheldonhull/markdownlint-cli2:latest
```

### Prek not running hooks

Ensure prek is installed:

```bash
prek install
```

### Permission errors with Docker

Ensure your user has permission to run Docker:

```bash
# Linux: add user to docker group
sudo usermod -aG docker $USER
# Then logout and login again
```

### Linting rules too strict

Create a local `.markdownlint-cli2.yaml` file to override specific rules:

```yaml
config:
  # Disable line length rule
  MD013: false
  # Disable sentences-per-line
  sentences-per-line: false
```

### VS Code commits failing

This configuration includes special handling for VS Code:

- TTY detection suppresses stderr in non-interactive mode
- Fixed files are auto-staged
- Set `PREK_SKIP=1` environment variable to bypass hooks entirely

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Lint Markdown

on: [push, pull_request]

jobs:
  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Prek
        run: cargo install prek

      - name: Run Markdown Linting
        run: prek run pre-push
```

### GitLab CI Example

```yaml
markdown-lint:
  image: docker:latest
  services:
    - docker:dind
  script:
    - apk add --no-cache cargo
    - cargo install prek
    - prek install
    - prek run pre-push
```

## Version Pinning

For production use, pin to specific versions:

```toml
# prek.toml

[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "v1.2.3"  # Pin to specific tag
config = "prek-markdown.toml"
```

And in `prek-markdown.toml`, use versioned image tags:

```toml
run = "docker pull preflight/markdownlint-cli2:v1.2.3"
```

## Contributing

To add new rules or update the configuration:

1. Edit `.markdownlint-cli2.yaml` or `prek-markdown.toml`
2. Test locally with `prek run pre-commit`
3. Update version in `Dockerfile.markdownlint` if needed
4. Rebuild and republish the Docker image
5. Create a new release tag

## Resources

- [Prek Documentation](https://github.com/prek-dev/prek)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [sentences-per-line Plugin](https://github.com/JoshuaKGoldberg/sentences-per-line)
- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
