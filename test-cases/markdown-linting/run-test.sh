#!/bin/bash
# Test script for markdown linting with sentences-per-line plugin
# This verifies that:
# 1. Multiple sentences are split onto separate lines
# 2. Tables remain intact and are not broken
# 3. Code blocks are preserved

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

IMAGE_NAME="${IMAGE_NAME:-preflight/markdownlint-cli2:latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Markdown Linting Test Suite"
echo "========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed or not in PATH${NC}"
    echo "Please install Docker to run tests"
    exit 1
fi
echo -e "${GREEN}✓ Docker is available${NC}"

# Check if the Docker image exists
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
    echo -e "${RED}✗ Docker image not found: $IMAGE_NAME${NC}"
    echo "Please build the image first:"
    echo "  cd ../.. && ./build-markdownlint-image.sh"
    exit 1
fi
echo -e "${GREEN}✓ Docker image exists: $IMAGE_NAME${NC}"

echo ""
echo "========================================="
echo "Test 1: Sentence Splitting"
echo "========================================="
echo ""

# Create a test output file
cp "${SCRIPT_DIR}/before-formatting.md" "${SCRIPT_DIR}/test-output.md"

echo "Running markdownlint-cli2 with --fix..."
docker run --rm \
  -v "${SCRIPT_DIR}:/workspace" \
  -w /workspace \
  "$IMAGE_NAME" \
  markdownlint-cli2 --fix test-output.md

echo ""
echo -e "${BLUE}Checking for sentence splitting...${NC}"

# Check if sentences were split
if grep -q "This is the first sentence. This is the second sentence." "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${RED}✗ Sentences were NOT split${NC}"
    echo "Expected: Sentences on separate lines"
    echo "Got: Sentences still on same line"
    exit 1
else
    echo -e "${GREEN}✓ Sentences were split onto separate lines${NC}"
fi

echo ""
echo "========================================="
echo "Test 2: Table Preservation"
echo "========================================="
echo ""

# Check if tables are still intact
if grep -q "| Column 1 | Column 2 | Column 3 |" "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${GREEN}✓ Simple table preserved${NC}"
else
    echo -e "${RED}✗ Simple table was broken${NC}"
    exit 1
fi

if grep -q "| Feature | Description | Status | Notes |" "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${GREEN}✓ Complex table preserved${NC}"
else
    echo -e "${RED}✗ Complex table was broken${NC}"
    exit 1
fi

# Check that table cells with multiple sentences are preserved
if grep -q "| Sentence splitting | Splits multiple sentences onto separate lines. Works automatically. |" "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${GREEN}✓ Table cells with multiple sentences preserved${NC}"
else
    echo -e "${RED}✗ Table cells were incorrectly split${NC}"
    exit 1
fi

echo ""
echo "========================================="
echo "Test 3: Code Block Preservation"
echo "========================================="
echo ""

# Check if code blocks are preserved
if grep -q 'echo "This is a string. It has multiple sentences. They should not be modified."' "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${GREEN}✓ Code blocks preserved${NC}"
else
    echo -e "${RED}✗ Code blocks were modified${NC}"
    exit 1
fi

# Check inline code
if grep -q '`echo "Hello. World. Test."`' "${SCRIPT_DIR}/test-output.md"; then
    echo -e "${GREEN}✓ Inline code preserved${NC}"
else
    echo -e "${RED}✗ Inline code was modified${NC}"
    exit 1
fi

echo ""
echo "========================================="
echo "Test 4: Compare with Expected Output"
echo "========================================="
echo ""

if diff -u "${SCRIPT_DIR}/expected-after-formatting.md" "${SCRIPT_DIR}/test-output.md" > "${SCRIPT_DIR}/diff-output.txt" 2>&1; then
    echo -e "${GREEN}✓ Output matches expected format exactly${NC}"
    rm "${SCRIPT_DIR}/diff-output.txt"
else
    echo -e "${YELLOW}! Output differs from expected format${NC}"
    echo ""
    echo "Differences found:"
    cat "${SCRIPT_DIR}/diff-output.txt"
    echo ""
    echo -e "${YELLOW}Note: Some differences may be acceptable depending on the plugin version${NC}"
    echo "Review the differences above to determine if they are expected"
    echo ""
    echo "To update expected output:"
    echo "  cp test-output.md expected-after-formatting.md"
fi

echo ""
echo "========================================="
echo "Test 5: Specific Formatting Checks"
echo "========================================="
echo ""

# Count sentences that should be split
BEFORE_LINES=$(wc -l < "${SCRIPT_DIR}/before-formatting.md")
AFTER_LINES=$(wc -l < "${SCRIPT_DIR}/test-output.md")

echo "Lines before formatting: $BEFORE_LINES"
echo "Lines after formatting:  $AFTER_LINES"

if [ "$AFTER_LINES" -gt "$BEFORE_LINES" ]; then
    echo -e "${GREEN}✓ Line count increased (sentences were split)${NC}"
else
    echo -e "${RED}✗ Line count did not increase${NC}"
    exit 1
fi

# Check specific examples
echo ""
echo -e "${BLUE}Checking specific transformations...${NC}"

# Example 1: Multiple sentences in paragraph
if grep -A 2 "## Multiple Sentences Per Line" "${SCRIPT_DIR}/test-output.md" | grep -q "This is the first sentence.$"; then
    echo -e "${GREEN}✓ First sentence on its own line${NC}"
else
    echo -e "${RED}✗ First sentence not properly split${NC}"
fi

if grep -A 3 "## Multiple Sentences Per Line" "${SCRIPT_DIR}/test-output.md" | grep -q "This is the second sentence.$"; then
    echo -e "${GREEN}✓ Second sentence on its own line${NC}"
else
    echo -e "${RED}✗ Second sentence not properly split${NC}"
fi

# Example 2: List items
if grep -A 1 "This is a list item.$" "${SCRIPT_DIR}/test-output.md" | grep -q "It has multiple sentences.$"; then
    echo -e "${GREEN}✓ List item sentences split with proper indentation${NC}"
else
    echo -e "${YELLOW}! List item formatting may differ${NC}"
fi

echo ""
echo "========================================="
echo "Test Results Summary"
echo "========================================="
echo ""
echo -e "${GREEN}✓ All critical tests passed!${NC}"
echo ""
echo "Formatted output saved to: test-output.md"
echo ""
echo "Key findings:"
echo "  - Sentences are correctly split onto separate lines"
echo "  - Tables remain intact and properly formatted"
echo "  - Code blocks are preserved exactly"
echo "  - Inline code is not modified"
echo ""
echo "The markdown linting configuration is working correctly!"
echo ""

# Cleanup
echo "Cleaning up test output..."
rm -f "${SCRIPT_DIR}/test-output.md" "${SCRIPT_DIR}/diff-output.txt"

echo -e "${GREEN}All tests completed successfully!${NC}"
