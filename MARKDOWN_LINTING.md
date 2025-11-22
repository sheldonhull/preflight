# Markdown Linting with Lefthook and Docker

This repository provides a **reusable, Docker-based markdown linting solution** that can be shared across multiple repositories without requiring each repo to maintain linting configuration files or Docker images.

## Features

- **Containerized**: Uses Docker to ensure consistent linting across all environments
- **Custom Plugin Support**: Includes the [sentences-per-line](https://github.com/JoshuaKGoldberg/sentences-per-line) plugin for better Git diffs
- **Remote Configuration**: Uses lefthook's remote config feature to share setup across repos
- **Auto-fix on Commit**: Automatically formats markdown files on `pre-commit`
- **Validation on Push**: Validates markdown without auto-fix on `pre-push`
- **Pre-pulled Images**: The `install` hook pulls the Docker image so hook execution is fast

## Quick Start for Other Repositories

### 1. Add Remote Configuration to Your Repo

In your repository, create or update `lefthook.yml`:

```yaml
# lefthook.yml

# Pull markdown linting configuration from this repo
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main  # or use a specific tag like v1.0.0 for stability
```

### 2. Install Lefthook

```bash
# If lefthook is not installed yet
npm install -g lefthook
# or: brew install lefthook
# or: go install github.com/evilmartians/lefthook@latest

# Initialize lefthook in your repo (this will also run the install hook)
lefthook install
```

That's it! The remote configuration will be automatically fetched, and the Docker image will be pulled during installation.

### 3. How It Works

- **On first install**: The Docker image is pulled (one-time setup)
- **On `git commit`**: Markdown files are automatically formatted with `--fix`
- **On `git push`**: Markdown files are validated (without auto-fix)

## For This Repository (Setup & Maintenance)

### Building the Docker Image

```bash
# Build the image locally
./build-markdownlint-image.sh

# Test the image
docker run --rm lefthook/markdownlint-cli2:latest markdownlint-cli2 --version
```

### Publishing to a Container Registry

For other repositories to use this without building, publish the image to a registry:

#### GitHub Container Registry (GHCR)

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Tag the image
docker tag lefthook/markdownlint-cli2:latest ghcr.io/sheldonhull/markdownlint-cli2:latest

# Push to registry
docker push ghcr.io/sheldonhull/markdownlint-cli2:latest
```

Then update `lefthook-markdown.yml` to reference `ghcr.io/sheldonhull/markdownlint-cli2:latest` instead of `lefthook/markdownlint-cli2:latest`.

#### Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag the image
docker tag lefthook/markdownlint-cli2:latest YOUR_USERNAME/markdownlint-cli2:latest

# Push to registry
docker push YOUR_USERNAME/markdownlint-cli2:latest
```

### Testing Locally

```bash
# Install lefthook in this repo
lefthook install

# Test the install hook (pulls Docker image)
lefthook run install

# Test pre-commit formatting
lefthook run pre-commit

# Test pre-push validation
lefthook run pre-push

# Or test on specific files
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  lefthook/markdownlint-cli2:latest \
  markdownlint-cli2 "README.md"
```

## Configuration Files

### `Dockerfile.markdownlint`

The Dockerfile that builds the linting image with:
- Node.js 20 Alpine (small footprint)
- markdownlint-cli2 (latest version)
- sentences-per-line plugin

### `lefthook-markdown.yml`

The remote lefthook configuration that defines:
- **install hook**: Pulls the Docker image
- **pre-commit hook**: Auto-formats markdown files
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

If a consuming repository needs different rules, they can create their own `.markdownlint-cli2.yaml` file locally. The local configuration will take precedence.

### Skip Linting for Specific Commits

```bash
# Skip all lefthook hooks
LEFTHOOK=0 git commit -m "docs: emergency fix"

# Skip just markdown linting using tags (if you add tags to the config)
LEFTHOOK_EXCLUDE=markdown git commit -m "docs: skip linting"
```

### Disable Specific Hooks

Create `lefthook-local.yml` in your repo (add to `.gitignore`):

```yaml
# lefthook-local.yml

pre-commit:
  commands:
    markdownlint-fmt:
      skip: true
```

## Architecture Decisions

### Why Docker?

- **Consistency**: Same linting environment across all machines and CI/CD
- **No Local Dependencies**: Don't need Node.js, npm, or packages installed locally
- **Version Control**: Lock specific versions of tools and plugins
- **Isolation**: No conflicts with project dependencies

### Why Lefthook Remote Configs?

- **DRY Principle**: Define configuration once, use everywhere
- **Centralized Updates**: Update linting rules in one place
- **No Config Sprawl**: Other repos don't need to maintain config files
- **Easy Adoption**: New repos add just 3 lines to their `lefthook.yml`

### Why sentences-per-line Plugin?

- **Better Git Diffs**: One sentence per line means cleaner, more readable diffs
- **Easier Reviews**: Changes to specific sentences are isolated
- **Conflict Reduction**: Fewer merge conflicts in documentation

## Troubleshooting

### Docker image not found

If you see "docker: image not found", build or pull the image:

```bash
# Build locally
./build-markdownlint-image.sh

# Or if published to a registry
docker pull ghcr.io/sheldonhull/markdownlint-cli2:latest
```

### Lefthook not running hooks

Ensure lefthook is installed:

```bash
lefthook install
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

      - name: Install Lefthook
        run: |
          curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
          sudo apt-get update
          sudo apt-get install lefthook

      - name: Run Markdown Linting
        run: lefthook run pre-push
```

### GitLab CI Example

```yaml
markdown-lint:
  image: docker:latest
  services:
    - docker:dind
  script:
    - apk add --no-cache curl bash
    - curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.alpine.sh' | bash
    - apk add lefthook
    - lefthook install
    - lefthook run pre-push
```

## Version Pinning

For production use, pin to specific versions:

```yaml
# lefthook.yml

remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: v1.2.3  # Pin to specific tag
```

And in `lefthook-markdown.yml`, use versioned image tags:

```yaml
docker pull lefthook/markdownlint-cli2:v1.2.3
```

## Contributing

To add new rules or update the configuration:

1. Edit `.markdownlint-cli2.jsonc` or `lefthook-markdown.yml`
2. Test locally with `lefthook run pre-commit`
3. Update version in `Dockerfile.markdownlint` if needed
4. Rebuild and republish the Docker image
5. Create a new release tag

## Resources

- [Lefthook Documentation](https://github.com/evilmartians/lefthook)
- [Lefthook Remote Configs](https://lefthook.dev/configuration/remotes.html)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [sentences-per-line Plugin](https://github.com/JoshuaKGoldberg/sentences-per-line)
- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
