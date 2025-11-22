# Using Lefthook Markdown Linting in Your Repository

This is a **quick reference guide** for using the markdown linting configuration from this repository in your own projects.

## TL;DR - 3 Lines to Add

Add this to your repository's `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main
```

Then run:

```bash
lefthook install
```

Done! Your repository now has automatic markdown linting and formatting.

## What You Get

- **Auto-format on commit**: Markdown files are automatically formatted when you commit
- **Validation on push**: Markdown is validated before pushing (prevents bad markdown from reaching remote)
- **Zero config**: No need to copy configuration files or maintain them
- **Containerized**: Works the same on every machine, no local dependencies

## How It Works

### On `git commit` (pre-commit hook)

```bash
# Automatically runs:
markdownlint-cli2 --fix "**/*.{md,markdown}"
```

- Fixes formatting issues
- Applies sentences-per-line rule
- Stages fixed files automatically

### On `git push` (pre-push hook)

```bash
# Automatically runs:
markdownlint-cli2 "**/*.{md,markdown}"
```

- Validates markdown files
- Fails if there are unfixable issues
- Prevents pushing broken documentation

### On `lefthook install` (install hook)

```bash
# Automatically runs:
docker pull lefthook/markdownlint-cli2:latest
```

- Pulls the Docker image once
- Subsequent hook runs are fast (no download needed)

## Customization

### Override Rules Locally

Create `.markdownlint-cli2.yaml` in your repository:

```yaml
config:
  default: true
  # Disable line length rule
  MD013: false
  # Downgrade to warning
  sentences-per-line:
    severity: warning
```

### Skip Hooks Temporarily

```bash
# Skip all hooks
LEFTHOOK=0 git commit -m "emergency fix"

# Skip pre-commit but still run pre-push
git commit --no-verify
```

### Disable Permanently (Not Recommended)

Create `lefthook-local.yml` (add to `.gitignore`):

```yaml
pre-commit:
  commands:
    markdownlint-fmt:
      skip: true

pre-push:
  commands:
    markdownlint-check:
      skip: true
```

## Requirements

- **Git**: Already have it if you're reading this
- **Lefthook**: Install with `brew install lefthook` or `npm install -g lefthook`
- **Docker**: Required to run the linting container

## Troubleshooting

### "Image not found" error

The image might not be published yet. Options:

1. Ask your team lead to publish the image
2. Build it locally: `./build-markdownlint-image.sh`
3. Temporarily disable: Add `skip: true` to `lefthook-local.yml`

### "Docker not running" error

Start Docker Desktop or the Docker daemon:

```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

### Linting is too strict

The rules are intentionally strict to maintain documentation quality.
If you need to disable specific rules, create a local `.markdownlint-cli2.jsonc` file.

### Want to run manually

```bash
# Format all markdown files
lefthook run pre-commit

# Validate all markdown files
lefthook run pre-push

# Run on specific files
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  lefthook/markdownlint-cli2:latest \
  markdownlint-cli2 --fix README.md
```

## Benefits

### For Individual Developers

- No need to remember linting commands
- Consistent formatting across the team
- Cleaner Git diffs (one sentence per line)
- Catches documentation issues before they're pushed

### For Teams

- Enforce documentation standards automatically
- Reduce review time (formatting is already correct)
- No "can you fix the formatting" comments in PRs
- Easy to adopt in new projects (3 lines of config)

### For Organizations

- Centralized configuration management
- Update rules in one place, apply everywhere
- Consistent documentation quality across all repos
- Reduce onboarding friction for new developers

## Advanced Usage

### Pin to Specific Version

For production stability, pin to a specific release:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: v1.0.0  # Use a specific tag
```

### Extend with Additional Hooks

You can add more hooks while keeping the remote markdown linting:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main

# Add your own hooks
pre-commit:
  commands:
    eslint:
      glob: "*.js"
      run: npm run lint

    tests:
      run: npm test
```

### Multiple Remote Configs

You can use multiple remote configs:

```yaml
remotes:
  - git_url: https://github.com/sheldonhull/preflight
    ref: main  # Markdown linting

  - git_url: https://github.com/YOUR_ORG/security-hooks
    ref: v2.1.0  # Security scanning
```

## CI/CD Integration

The same Docker image works in CI/CD. Example for GitHub Actions:

```yaml
- name: Lint Markdown
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace -w /workspace \
      lefthook/markdownlint-cli2:latest \
      markdownlint-cli2 "**/*.{md,markdown}"
```

## Learn More

- Full documentation: [MARKDOWN_LINTING.md](./MARKDOWN_LINTING.md)
- Lefthook docs: [github.com/evilmartians/lefthook](https://github.com/evilmartians/lefthook)
- Remote config docs: [lefthook.dev/configuration/remotes.html](https://lefthook.dev/configuration/remotes.html)
