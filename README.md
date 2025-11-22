# preflight

Reusable Lefthook hooks and configurations to reduce copy-pasta across projects.

## 🚀 Remote Hook Configs

This repository provides **remote lefthook configurations** that can be shared across multiple repositories without duplicating configuration files.

### Available Configurations

#### Markdown Linting with Docker

Docker-based markdown linting with `markdownlint-cli2` and the `sentences-per-line` plugin.

**Features:**
- 🐳 Containerized linting (consistent across all environments)
- ✨ Auto-fixes markdown on commit
- ✅ Validates markdown on push
- 📝 Better Git diffs with sentences-per-line rule

**Quick Start:**

Add 3 lines to your repository's `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main
```

Then run:

```bash
lefthook install
```

Done! Your repository now has automatic markdown linting.

**Documentation:**
- [Full Documentation](./MARKDOWN_LINTING.md) - Complete setup and usage guide
- [Quick Reference](./REMOTE_CONFIG_USAGE.md) - TL;DR for consumers
- [Example Configuration](./examples/remote-markdown-linting/) - Sample setup

## 📚 What's Inside

- **Docker-based markdown linting** - Consistent linting across all repos
- **Remote configurations** - Share hooks without config duplication
- **Automated testing** - Verify your setup works
- **CI/CD workflows** - Build and publish Docker images

## 🛠️ For Maintainers

### Building the Docker Image

```bash
./build-markdownlint-image.sh
```

### Running Tests

```bash
./test-markdown-linting.sh
```

### Publishing to GHCR

The Docker image is automatically built and published via GitHub Actions on push to `main`.

## 📖 Learn More

- [Lefthook Documentation](https://github.com/evilmartians/lefthook)
- [Remote Configs Guide](https://github.com/evilmartians/lefthook/blob/master/docs/configuration.md#remotes)
