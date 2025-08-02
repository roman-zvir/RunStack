#!/usr/bin/env bash

# Smart deployment script that detects branch and deploys to appropriate environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


# Azure Container Registry (ACR) settings
ACR_NAME="developmentbranch"
ACR_LOGIN_SERVER="developmentbranch.azurecr.io"


# Azure Container Registry (ACR) settings
ACR_NAME="developmentbranch"
ACR_LOGIN_SERVER="developmentbranch.azurecr.io"

# Detect current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
print_status "Detected branch: $CURRENT_BRANCH"

# Login to Azure Container Registry
print_status "Logging in to Azure Container Registry: $ACR_NAME"
az acr login --name $ACR_NAME

# Build and push Docker images to ACR
build_and_push() {
    IMAGE_NAME=$1
    IMAGE_TAG=$2
    DOCKERFILE_PATH=$3
    CONTEXT_PATH=$4
    FULL_IMAGE_NAME="$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
    print_status "Building Docker image: $FULL_IMAGE_NAME"
    docker build -t $FULL_IMAGE_NAME -f $DOCKERFILE_PATH $CONTEXT_PATH
    print_status "Pushing Docker image: $FULL_IMAGE_NAME"
    docker push $FULL_IMAGE_NAME
}

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    print_status "Pushing production images (backend-prod, frontend-prod)"
    build_and_push backend-prod latest ./backend/Dockerfile ./backend
    build_and_push frontend-prod latest ./frontend/Dockerfile ./frontend
elif [[ "$CURRENT_BRANCH" == "dev" || "$CURRENT_BRANCH" == "Dev" ]]; then
    print_status "Pushing development images (backend-dev, frontend-dev)"
    build_and_push backend-dev latest ./backend/Dockerfile ./backend
    build_and_push frontend-dev latest ./frontend/Dockerfile ./frontend
else
    print_status "Branch not recognized. Defaulting to development images."
    build_and_push backend-dev latest ./backend/Dockerfile ./backend
    build_and_push frontend-dev latest ./frontend/Dockerfile ./frontend
fi

print_success "🎉 Deployment completed!"