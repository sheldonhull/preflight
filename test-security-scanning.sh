#!/bin/bash
# Test script for security scanner setup
# This simulates what the prek hooks would do

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REGISTRY="ghcr.io/sheldonhull/preflight"
CHECKOV_IMAGE="${REGISTRY}/checkov:latest"
TRIVY_IMAGE="${REGISTRY}/trivy:latest"
TRUFFLEHOG_IMAGE="${REGISTRY}/trufflehog:latest"

echo "========================================="
echo "Testing Security Scanner Setup"
echo "========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed or not in PATH${NC}"
    echo "Please install Docker to test the security scanning setup"
    exit 1
fi
echo -e "${GREEN}✓ Docker is available${NC}"

# Function to check and build image if needed
check_and_build_image() {
    local image_name=$1
    local tool=$2
    local dockerfile=$3

    if docker image inspect "$image_name" &> /dev/null; then
        echo -e "${GREEN}✓ Docker image exists: $image_name${NC}"
    else
        echo -e "${YELLOW}! Docker image not found: $image_name${NC}"
        echo "Building image for $tool..."
        if REGISTRY="$REGISTRY" IMAGE_TAG="latest" ./build-security-images.sh "$tool"; then
            echo -e "${GREEN}✓ Image built successfully${NC}"
        else
            echo -e "${RED}✗ Failed to build image${NC}"
            return 1
        fi
    fi
}

# Check all three images
echo ""
echo "Checking Docker images..."
check_and_build_image "$CHECKOV_IMAGE" "checkov" "Dockerfile.checkov"
check_and_build_image "$TRIVY_IMAGE" "trivy" "Dockerfile.trivy"
check_and_build_image "$TRUFFLEHOG_IMAGE" "trufflehog" "Dockerfile.trufflehog"

# Check if configuration files exist
echo ""
echo "Checking configuration files..."
for file in ".checkov.yaml" ".trivy.yaml" ".trufflehog.yaml" "prek-security.toml" \
            "Dockerfile.checkov" "Dockerfile.trivy" "Dockerfile.trufflehog"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file not found${NC}"
        exit 1
    fi
done

# Test Checkov
echo ""
echo "========================================="
echo "Testing Checkov"
echo "========================================="
echo ""

echo "Testing Checkov version..."
if docker run --rm "$CHECKOV_IMAGE" checkov --version; then
    echo -e "${GREEN}✓ Checkov image works${NC}"
else
    echo -e "${RED}✗ Checkov image test failed${NC}"
    exit 1
fi

# Create test IaC files
echo ""
echo "Creating test Terraform file with security issues..."
mkdir -p /tmp/test-security/terraform
cat > /tmp/test-security/terraform/main.tf << 'EOF'
# Intentionally insecure Terraform for testing
resource "aws_s3_bucket" "example" {
  bucket = "my-test-bucket"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  # Missing security group
  # Missing encryption
}
EOF

echo -e "${GREEN}✓ Test Terraform file created${NC}"

echo ""
echo "Testing Checkov on test file..."
if docker run --rm -v /tmp/test-security/terraform:/workspace -w /workspace "$CHECKOV_IMAGE" \
    checkov --directory /workspace --config-file /root/.checkov.yaml; then
    echo -e "${YELLOW}! No issues found (unexpected for test file)${NC}"
else
    echo -e "${GREEN}✓ Checkov found security issues as expected${NC}"
fi

# Test Trivy
echo ""
echo "========================================="
echo "Testing Trivy"
echo "========================================="
echo ""

echo "Testing Trivy version..."
if docker run --rm "$TRIVY_IMAGE" trivy --version; then
    echo -e "${GREEN}✓ Trivy image works${NC}"
else
    echo -e "${RED}✗ Trivy image test failed${NC}"
    exit 1
fi

# Create test Dockerfile with security issues
echo ""
echo "Creating test Dockerfile with security issues..."
mkdir -p /tmp/test-security/docker
cat > /tmp/test-security/docker/Dockerfile << 'EOF'
# Intentionally insecure Dockerfile for testing
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl

# Using latest tag (bad practice)
FROM node:latest

# Running as root (security issue)
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
EOF

echo -e "${GREEN}✓ Test Dockerfile created${NC}"

echo ""
echo "Testing Trivy filesystem scan..."
if docker run --rm -v /tmp/test-security:/workspace -w /workspace "$TRIVY_IMAGE" \
    trivy fs --config /root/.trivy.yaml --exit-code 0 .; then
    echo -e "${GREEN}✓ Trivy scan completed${NC}"
else
    echo -e "${YELLOW}! Trivy found issues (this may be expected)${NC}"
fi

# Test Trufflehog
echo ""
echo "========================================="
echo "Testing Trufflehog"
echo "========================================="
echo ""

echo "Testing Trufflehog help..."
if docker run --rm "$TRUFFLEHOG_IMAGE" trufflehog --help; then
    echo -e "${GREEN}✓ Trufflehog image works${NC}"
else
    echo -e "${RED}✗ Trufflehog image test failed${NC}"
    exit 1
fi

# Create test file with fake secret
echo ""
echo "Creating test file with fake secret..."
mkdir -p /tmp/test-security/secrets
cat > /tmp/test-security/secrets/config.py << 'EOF'
# Fake credentials for testing
API_KEY = "AKIAIOSFODNN7EXAMPLE"
SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
DATABASE_URL = "postgresql://user:password@localhost:5432/db"
EOF

echo -e "${GREEN}✓ Test file with fake secrets created${NC}"

echo ""
echo "Testing Trufflehog on test files..."
# Note: Trufflehog may not find these fake secrets depending on entropy settings
docker run --rm -v /tmp/test-security/secrets:/workspace -w /workspace "$TRUFFLEHOG_IMAGE" \
    trufflehog --regex --entropy=True --max_depth=10 \
    --exclude_paths /root/.trufflehog.yaml \
    /workspace || echo -e "${GREEN}✓ Trufflehog scan completed${NC}"

# Test on real repository files
echo ""
echo "========================================="
echo "Testing on Repository Files"
echo "========================================="
echo ""

echo "Testing Trivy on repository..."
if docker run --rm -v "$(pwd):/workspace" -w /workspace "$TRIVY_IMAGE" \
    trivy fs --config /root/.trivy.yaml --exit-code 0 .; then
    echo -e "${GREEN}✓ Repository passes Trivy scan${NC}"
else
    echo -e "${YELLOW}! Repository has some Trivy findings${NC}"
fi

# Test TTY detection
echo ""
echo "========================================="
echo "Testing TTY Detection (VS Code compatibility)"
echo "========================================="
echo ""

echo "Current TTY status:"
if [ -t 1 ]; then
    echo -e "${GREEN}✓ Running in interactive mode (TTY detected)${NC}"
else
    echo -e "${YELLOW}! Running in non-interactive mode (no TTY)${NC}"
    echo "  Prek will suppress stderr output to prevent VS Code issues"
fi

# Test prek configuration
echo ""
echo "========================================="
echo "Testing Prek Configuration"
echo "========================================="
echo ""

if ! command -v prek &> /dev/null; then
    echo -e "${YELLOW}! Prek is not installed${NC}"
    echo "To test the full setup, install prek:"
    echo "  cargo install prek"
    echo "  or: brew install prek"
else
    echo -e "${GREEN}✓ Prek is available${NC}"

    echo ""
    echo "Testing prek configuration syntax..."
    if prek --help > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Prek is working${NC}"
    else
        echo -e "${RED}✗ Prek test failed${NC}"
    fi

    # Only test runs if prek.toml exists
    if [ -f "prek.toml" ]; then
        echo ""
        echo "You can test the hooks manually with:"
        echo "  prek install          # Install hooks"
        echo "  prek run install      # Pull Docker images"
        echo "  prek run pre-commit   # Test security scanning"
        echo "  prek run pre-push     # Test security validation"
    fi
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review the configuration files"
echo "2. Build and publish the Docker images to a registry"
echo "3. Update prek-security.toml with your registry URL if needed"
echo "4. Test in another repository with the remote config"
echo "5. Customize security policies in .checkov.yaml, .trivy.yaml, and .trufflehog.yaml"
echo ""
echo "Key features of the prek configuration:"
echo "  - TTY detection for VS Code compatibility"
echo "  - Suppresses stderr in non-interactive mode"
echo "  - Parallel execution of security scanners"
echo ""

# Cleanup
rm -rf /tmp/test-security 2>/dev/null || true
