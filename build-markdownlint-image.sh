#!/bin/bash
# Build script for the markdownlint Docker image
# This builds the image locally for testing and can be used for CI/CD

set -e

IMAGE_NAME="${IMAGE_NAME:-preflight/markdownlint-cli2}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Building markdownlint Docker image..."
docker build -f Dockerfile.markdownlint -t "${IMAGE_NAME}:${IMAGE_TAG}" .

echo ""
echo "Image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To test the image:"
echo "  docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} markdownlint-cli2 --version"
echo ""
echo "To tag for a registry:"
echo "  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ghcr.io/YOUR_ORG/markdownlint-cli2:${IMAGE_TAG}"
echo ""
echo "To push to a registry:"
echo "  docker push ghcr.io/YOUR_ORG/markdownlint-cli2:${IMAGE_TAG}"
