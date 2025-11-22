#!/bin/bash
# Build script for security scanner Docker images
# This builds the images locally for testing and can be used for CI/CD

set -e

# Default image registry
REGISTRY="${REGISTRY:-ghcr.io/sheldonhull/lefthook}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Function to build a single image
build_image() {
    local tool=$1
    local dockerfile=$2
    local image_name="${REGISTRY}/${tool}:${IMAGE_TAG}"

    echo "Building ${tool} Docker image..."
    docker build -f "${dockerfile}" -t "${image_name}" .

    echo ""
    echo "✓ Image built successfully: ${image_name}"
    echo ""
    echo "To test the image:"
    echo "  docker run --rm ${image_name} ${tool} --version"
    echo ""
}

# Parse arguments
if [ $# -eq 0 ]; then
    # No arguments - build all images
    TOOLS=("checkov" "trivy" "trufflehog")
else
    # Build specific tools
    TOOLS=("$@")
fi

# Build requested images
for tool in "${TOOLS[@]}"; do
    case $tool in
        checkov)
            build_image "checkov" "Dockerfile.checkov"
            ;;
        trivy)
            build_image "trivy" "Dockerfile.trivy"
            ;;
        trufflehog)
            build_image "trufflehog" "Dockerfile.trufflehog"
            ;;
        *)
            echo "Unknown tool: $tool"
            echo "Supported tools: checkov, trivy, trufflehog"
            exit 1
            ;;
    esac
done

echo ""
echo "All requested images built successfully!"
echo ""
echo "To push to registry:"
echo "  docker push ${REGISTRY}/checkov:${IMAGE_TAG}"
echo "  docker push ${REGISTRY}/trivy:${IMAGE_TAG}"
echo "  docker push ${REGISTRY}/trufflehog:${IMAGE_TAG}"
echo ""
