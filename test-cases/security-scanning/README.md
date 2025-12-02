# Security Scanner Test Cases

This directory contains test cases for validating the security scanners (Checkov, Trivy, and Trufflehog) are working correctly.

## Directory Structure

```
test-cases/security-scanning/
├── checkov/              # Checkov test cases (IaC files)
│   └── insecure.tf       # Intentionally insecure Terraform config
├── trivy/                # Trivy test cases (Dockerfiles, configs)
│   └── Dockerfile.insecure  # Intentionally insecure Dockerfile
└── trufflehog/           # Trufflehog test cases (files with secrets)
    └── secrets.example   # Fake credentials for testing
```

## Purpose

These test files contain **intentionally insecure** configurations and **fake credentials** to verify that the security scanners are functioning properly:

- **checkov/**: Contains Infrastructure as Code files with known security issues
- **trivy/**: Contains Dockerfiles and configuration files with vulnerabilities
- **trufflehog/**: Contains files with fake secrets to test secret detection

## Important Notes

⚠️ **WARNING**: All credentials and secrets in these test files are **FAKE** and for testing purposes only. They are not real credentials and will not provide access to any systems.

## Usage

Run the test script to validate all scanners:

```bash
./test-security-scanning.sh
```

Or test individual scanners:

```bash
# Test Checkov
docker run --rm -v "$(pwd)/test-cases/security-scanning/checkov:/workspace" \
  -w /workspace ghcr.io/sheldonhull/lefthook/checkov:latest \
  checkov --directory /workspace

# Test Trivy
docker run --rm -v "$(pwd)/test-cases/security-scanning/trivy:/workspace" \
  -w /workspace ghcr.io/sheldonhull/lefthook/trivy:latest \
  trivy config /workspace

# Test Trufflehog
docker run --rm -v "$(pwd)/test-cases/security-scanning/trufflehog:/workspace" \
  -w /workspace ghcr.io/sheldonhull/lefthook/trufflehog:latest \
  trufflehog --regex --entropy=True /workspace
```

## Expected Results

- **Checkov**: Should detect multiple security issues in the Terraform file
- **Trivy**: Should find misconfigurations and best practice violations in the Dockerfile
- **Trufflehog**: Should detect fake secrets in the secrets.example file

If a scanner does **not** detect issues in these files, there may be a configuration problem.
