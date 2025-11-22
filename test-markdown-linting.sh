#!/bin/bash
# Test script for markdown linting setup
# This simulates what the lefthook hooks would do

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

IMAGE_NAME="lefthook/markdownlint-cli2:latest"

echo "========================================="
echo "Testing Markdown Linting Setup"
echo "========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed or not in PATH${NC}"
    echo "Please install Docker to test the linting setup"
    exit 1
fi
echo -e "${GREEN}✓ Docker is available${NC}"

# Check if the Docker image exists
if docker image inspect "$IMAGE_NAME" &> /dev/null; then
    echo -e "${GREEN}✓ Docker image exists: $IMAGE_NAME${NC}"
else
    echo -e "${YELLOW}! Docker image not found: $IMAGE_NAME${NC}"
    echo "Building image..."
    if ./build-markdownlint-image.sh; then
        echo -e "${GREEN}✓ Image built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build image${NC}"
        exit 1
    fi
fi

# Check if configuration files exist
echo ""
echo "Checking configuration files..."
for file in ".markdownlint-cli2.yaml" ".markdownlint.yaml" "lefthook-markdown.yml" "Dockerfile.markdownlint"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file not found${NC}"
        exit 1
    fi
done

# Test the Docker image
echo ""
echo "Testing Docker image..."
if docker run --rm "$IMAGE_NAME" markdownlint-cli2 --version; then
    echo -e "${GREEN}✓ Docker image works${NC}"
else
    echo -e "${RED}✗ Docker image test failed${NC}"
    exit 1
fi

# Create a test markdown file with issues
echo ""
echo "Creating test markdown file with linting issues..."
cat > /tmp/test-lint.md << 'EOF'
# Test Document
This is a sentence. This is another sentence on the same line.
This line is too long and exceeds the typical line length recommendations for markdown files and should be split across multiple lines.

## Section 2
- List item one
- List item two
EOF

echo -e "${GREEN}✓ Test file created at /tmp/test-lint.md${NC}"

# Test linting (should find issues)
echo ""
echo "Testing linting (should find issues)..."
if docker run --rm -v /tmp:/workspace -w /workspace "$IMAGE_NAME" \
    markdownlint-cli2 test-lint.md 2>&1 | tee /tmp/lint-output.txt; then
    echo -e "${YELLOW}! No issues found (unexpected)${NC}"
else
    echo -e "${GREEN}✓ Linting found issues as expected${NC}"
fi

# Test auto-fix
echo ""
echo "Testing auto-fix..."
docker run --rm -v /tmp:/workspace -w /workspace "$IMAGE_NAME" \
    markdownlint-cli2 --fix test-lint.md

echo ""
echo "Fixed content:"
cat /tmp/test-lint.md
echo ""

# Test linting on real repository files
echo ""
echo "Testing on repository markdown files..."
echo ""

MD_FILES=$(find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" | head -5)

if [ -z "$MD_FILES" ]; then
    echo -e "${YELLOW}! No markdown files found in repository${NC}"
else
    echo "Found markdown files:"
    echo "$MD_FILES"
    echo ""
    echo "Running linter on repository files (check mode)..."

    if docker run --rm -v "$(pwd):/workspace" -w /workspace "$IMAGE_NAME" \
        markdownlint-cli2 "**/*.{md,markdown}" "#node_modules" "#vendor" "#.git" 2>&1; then
        echo -e "${GREEN}✓ All repository markdown files pass linting${NC}"
    else
        echo -e "${YELLOW}! Some repository markdown files have linting issues${NC}"
        echo "  This is normal - you can fix them with: lefthook run pre-commit"
    fi
fi

# Test lefthook configuration
echo ""
echo "========================================="
echo "Testing Lefthook Configuration"
echo "========================================="
echo ""

if ! command -v lefthook &> /dev/null; then
    echo -e "${YELLOW}! Lefthook is not installed${NC}"
    echo "To test the full setup, install lefthook:"
    echo "  brew install lefthook"
    echo "  or: go install github.com/evilmartians/lefthook@latest"
else
    echo -e "${GREEN}✓ Lefthook is available${NC}"

    echo ""
    echo "Testing lefthook configuration syntax..."
    if lefthook run --help > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Lefthook is working${NC}"
    else
        echo -e "${RED}✗ Lefthook test failed${NC}"
    fi

    # Only test runs if lefthook.yml exists
    if [ -f "lefthook.yml" ]; then
        echo ""
        echo "You can test the hooks manually with:"
        echo "  lefthook install          # Install hooks"
        echo "  lefthook run install      # Pull Docker image"
        echo "  lefthook run pre-commit   # Test formatting"
        echo "  lefthook run pre-push     # Test validation"
    fi
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests completed!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review the configuration files"
echo "2. Build and publish the Docker image to a registry"
echo "3. Update lefthook-markdown.yml with your registry URL"
echo "4. Test in another repository with the remote config"
echo ""
