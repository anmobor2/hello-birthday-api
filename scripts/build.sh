#!/bin/bash
set -euo pipefail

# Build script for Hello API application
# This script builds the Docker image and pushes it to the repository
# Usage: ./build.sh [version]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="hello-api"
BUILD_TIMESTAMP=$(date +%Y%m%d%H%M%S)
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "nogit")
VERSION=${1:-"${BUILD_TIMESTAMP}-${GIT_HASH}"}
AWS_REGION=${AWS_REGION:-"eu-west-1"}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"

echo -e "${YELLOW}Starting build process for ${APP_NAME}:${VERSION}${NC}"

# Validate environment
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}Error: AWS_ACCOUNT_ID is not set and couldn't be automatically determined.${NC}"
    echo "Please set the AWS_ACCOUNT_ID environment variable or configure AWS CLI."
    exit 1
fi

# Create versions file to track this build
mkdir -p .build
cat > .build/version.json <<EOF
{
    "appName": "${APP_NAME}",
    "version": "${VERSION}",
    "buildTimestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "gitCommit": "${GIT_HASH}",
    "builtBy": "$(whoami)@$(hostname)"
}
EOF

# Verify Docker is running
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker daemon is not running.${NC}"
    exit 1
fi

# Login to ECR
echo -e "${YELLOW}Logging in to AWS ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO} || {
    echo -e "${RED}Failed to login to ECR. Check your AWS credentials.${NC}"
    exit 1
}

# Create ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names ${APP_NAME} --region ${AWS_REGION} > /dev/null 2>&1 || {
    echo -e "${YELLOW}Creating ECR repository ${APP_NAME}...${NC}"
    aws ecr create-repository --repository-name ${APP_NAME} --region ${AWS_REGION}
}

# Build the Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build \
    --build-arg APP_VERSION=${VERSION} \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --build-arg VCS_REF=${GIT_HASH} \
    -t ${APP_NAME}:${VERSION} \
    -t ${APP_NAME}:latest \
    -f docker/Dockerfile .

# Tag the image for ECR
echo -e "${YELLOW}Tagging image for ECR...${NC}"
docker tag ${APP_NAME}:${VERSION} ${ECR_REPO}:${VERSION}
docker tag ${APP_NAME}:latest ${ECR_REPO}:latest

# Push the image to ECR
echo -e "${YELLOW}Pushing image to ECR...${NC}"
docker push ${ECR_REPO}:${VERSION}
docker push ${ECR_REPO}:latest

# Save image details for deployment
echo ${ECR_REPO}:${VERSION} > .build/image.txt

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "Image: ${ECR_REPO}:${VERSION}"
echo -e "Image details saved to .build/image.txt"
echo -e "Version information saved to .build/version.json"

exit 0