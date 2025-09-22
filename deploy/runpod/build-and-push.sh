#!/bin/bash
# Build and push script for Runpod deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker Hub username is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Docker Hub username not provided${NC}"
    echo "Usage: ./build-and-push.sh <dockerhub-username> [tag]"
    exit 1
fi

DOCKER_USERNAME=$1
TAG=${2:-latest}
IMAGE_NAME="aiva-runpod"

echo -e "${YELLOW}Building NVIDIA AI Virtual Assistant for Runpod...${NC}"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Warning: .env file not found. Creating from template...${NC}"
    cp deploy/runpod/runpod-template.env .env
    echo -e "${RED}Please edit .env file and add your API keys before deploying!${NC}"
fi

# Build the Docker image
echo -e "${GREEN}Building Docker image...${NC}"
docker build -f deploy/runpod/Dockerfile.runpod -t ${IMAGE_NAME}:${TAG} .

if [ $? -ne 0 ]; then
    echo -e "${RED}Docker build failed!${NC}"
    exit 1
fi

# Tag the image
echo -e "${GREEN}Tagging image...${NC}"
docker tag ${IMAGE_NAME}:${TAG} ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

# Login to Docker Hub
echo -e "${YELLOW}Please login to Docker Hub:${NC}"
docker login

# Push the image
echo -e "${GREEN}Pushing image to Docker Hub...${NC}"
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}${NC}"
    echo -e "${YELLOW}You can now use this image in Runpod!${NC}"
    echo -e "${YELLOW}Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}${NC}"
else
    echo -e "${RED}Failed to push image!${NC}"
    exit 1
fi