# Example: Remote Markdown Linting

This example demonstrates how to use the remote markdown linting configuration in another repository.

## Setup

1. Copy the `lefthook.yml` file to your repository's root directory
2. Run `lefthook install`

## What Gets Configured

When you use this remote configuration, your repository automatically gets:

### Install Hook

Pulls the Docker image when you run `lefthook install`:

```bash
docker pull lefthook/markdownlint-cli2:latest
```

### Pre-Commit Hook

Automatically formats markdown files before committing:

```bash
markdownlint-cli2 --fix "**/*.{md,markdown}"
```

Fixed files are automatically staged.

### Pre-Push Hook

Validates markdown files before pushing:

```bash
markdownlint-cli2 "**/*.{md,markdown}"
```

Push is blocked if validation fails.

## Testing

```bash
# Test the install hook
lefthook run install

# Test pre-commit formatting
lefthook run pre-commit

# Test pre-push validation
lefthook run pre-push
```

## Customization

If you need to override or extend the configuration, you can add commands directly to your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main

# Override or extend with local configuration
pre-commit:
  commands:
    my-custom-check:
      run: echo "Running custom check"
```

Or create a `.markdownlint-cli2.yaml` file to customize linting rules:

```yaml
config:
  default: true
  # Disable line length rule
  MD013: false
```

## Skipping Hooks

Temporarily skip hooks when needed:

```bash
# Skip all hooks
LEFTHOOK=0 git commit -m "emergency fix"

# Skip pre-commit verification
git commit --no-verify -m "skip pre-commit"
```

## Requirements

- Git (obviously)
- [Lefthook](https://github.com/evilmartians/lefthook) installed
- Docker installed and running

## See Also

- [Full Documentation](../../MARKDOWN_LINTING.md)
- [Quick Reference](../../REMOTE_CONFIG_USAGE.md)
