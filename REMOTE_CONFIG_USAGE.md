# Using Prek Markdown Linting in Your Repository

This is a **quick reference guide** for using the markdown linting configuration from this repository in your own projects.

## TL;DR - Add to Your prek.toml

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

Done! Your repository now has automatic markdown linting and formatting.

## What You Get

- **Auto-format on commit**: Markdown files are automatically formatted when you commit
- **Auto-staging**: Fixed files are automatically staged (no extra step needed!)
- **Validation on push**: Markdown is validated before pushing (prevents bad markdown from reaching remote)
- **Zero config**: No need to copy configuration files or maintain them
- **Containerized**: Works the same on every machine, no local dependencies
- **VS Code compatible**: TTY detection and stderr suppression for non-interactive environments

## How It Works

### On `git commit` (pre-commit hook)

```bash
# Automatically runs:
markdownlint-cli2 --fix "**/*.{md,markdown}"
# Then stages any fixed files
git add <modified-markdown-files>
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

### On `prek install` (install hook)

```bash
# Automatically runs:
docker pull preflight/markdownlint-cli2:latest
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
PREK_SKIP=1 git commit -m "emergency fix"

# Skip pre-commit but still run pre-push
git commit --no-verify
```

### Disable Permanently (Not Recommended)

Create `prek-local.toml` (add to `.gitignore`):

```toml
# prek-local.toml

[hooks.pre-commit.commands.markdownlint-fmt]
skip = true

[hooks.pre-push.commands.markdownlint-check]
skip = true
```

## Requirements

- **Git**: Already have it if you're reading this
- **Prek**: Install with `cargo install prek` or `brew install prek`
- **Docker**: Required to run the linting container

## Troubleshooting

### "Image not found" error

The image might not be published yet.
Options:

1. Ask your team lead to publish the image
2. Build it locally: `./build-markdownlint-image.sh`
3. Temporarily disable: Add `skip = true` to `prek-local.toml`

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
If you need to disable specific rules, create a local `.markdownlint-cli2.yaml` file.

### VS Code commits failing

This configuration includes special handling for VS Code:

- TTY detection suppresses stderr in non-interactive mode
- Fixed files are auto-staged so commits work without extra steps
- Set `PREK_SKIP=1` environment variable to bypass hooks entirely

### Want to run manually

```bash
# Format all markdown files
prek run pre-commit

# Validate all markdown files
prek run pre-push

# Run on specific files
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  preflight/markdownlint-cli2:latest \
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
- Easy to adopt in new projects

### For Organizations

- Centralized configuration management
- Update rules in one place, apply everywhere
- Consistent documentation quality across all repos
- Reduce onboarding friction for new developers

## Advanced Usage

### Pin to Specific Version

For production stability, pin to a specific release:

```toml
[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "v1.0.0"  # Use a specific tag
config = "prek-markdown.toml"
```

### Extend with Additional Hooks

You can add more hooks while keeping the remote markdown linting:

```toml
[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "main"
config = "prek-markdown.toml"

# Add your own hooks
[hooks.pre-commit.commands.eslint]
name = "ESLint"
glob = "*.js"
run = "npm run lint"

[hooks.pre-commit.commands.tests]
name = "Run tests"
run = "npm test"
```

### Multiple Remote Configs

You can use multiple remote configs:

```toml
[remotes.markdown]
url = "https://github.com/sheldonhull/preflight"
ref = "main"
config = "prek-markdown.toml"

[remotes.security]
url = "https://github.com/sheldonhull/preflight"
ref = "main"
config = "prek-security.toml"
```

## CI/CD Integration

The same Docker image works in CI/CD.
Example for GitHub Actions:

```yaml
- name: Lint Markdown
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace -w /workspace \
      preflight/markdownlint-cli2:latest \
      markdownlint-cli2 "**/*.{md,markdown}"
```

## Learn More

- Full documentation: [MARKDOWN_LINTING.md](./MARKDOWN_LINTING.md)
- Prek docs: [github.com/prek-dev/prek](https://github.com/prek-dev/prek)
