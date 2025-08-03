#!/bin/bash

# GitHub Packages Setup Script
# This script helps you set up GitHub Packages integration for your Kubernetes cluster

set -e

echo "🚀 GitHub Packages Setup for React Python Playground"
echo "===================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_step "Checking requirements..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "docker is not installed. Please install it first."
        exit 1
    fi
    
    print_status "All requirements satisfied!"
}

# Create Kubernetes secret for GitHub Container Registry
create_k8s_secret() {
    print_step "Creating Kubernetes secret for GitHub Container Registry..."
    
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    read -s -p "Enter your GitHub Personal Access Token (with packages:read permission): " GITHUB_TOKEN
    echo
    
    # Create the secret
    kubectl create secret docker-registry ghcr-secret \
        --docker-server=ghcr.io \
        --docker-username="$GITHUB_USERNAME" \
        --docker-password="$GITHUB_TOKEN" \
        --docker-email="$GITHUB_USERNAME@users.noreply.github.com" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_status "Kubernetes secret 'ghcr-secret' created successfully!"
}

# Test image pull
test_image_pull() {
    print_step "Testing image pull from GitHub Packages..."
    
    # Try to pull the images (this will help verify access)
    if docker pull ghcr.io/roman-zvir/frontend-prod:latest 2>/dev/null; then
        print_status "Successfully pulled frontend-prod image!"
    else
        print_warning "Could not pull frontend-prod image. This is normal if the image hasn't been built yet."
    fi
    
    if docker pull ghcr.io/roman-zvir/backend-prod:latest 2>/dev/null; then
        print_status "Successfully pulled backend-prod image!"
    else
        print_warning "Could not pull backend-prod image. This is normal if the image hasn't been built yet."
    fi
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_step "Deploying GitHub Packages manifests to Kubernetes..."
    
    if [ -d "k8s/github-packages" ]; then
        kubectl apply -f k8s/github-packages/
        print_status "Deployed GitHub Packages manifests!"
        
        print_step "Checking deployment status..."
        kubectl get deployments -l source=github-packages
        kubectl get services -l source=github-packages
    else
        print_error "GitHub Packages manifests directory not found!"
        exit 1
    fi
}

# Show package information
show_package_info() {
    print_step "GitHub Packages Information"
    echo "=============================="
    echo
    echo "📦 Your packages will be available at:"
    echo "   Frontend: ghcr.io/roman-zvir/frontend-prod:latest"
    echo "   Backend:  ghcr.io/roman-zvir/backend-prod:latest"
    echo
    echo "🔗 View your packages:"
    echo "   https://github.com/roman-zvir?tab=packages"
    echo
    echo "🏷️ Available tags:"
    echo "   - prod / prod-latest    (main branch)"
    echo "   - dev / dev-latest      (dev branch)"
    echo "   - prod-<commit-sha>     (specific commits)"
    echo "   - dev-<commit-sha>      (specific commits)"
    echo
    echo "🚀 To trigger a build, push to main or dev branch:"
    echo "   git push origin main    # Triggers prod build"
    echo "   git push origin dev     # Triggers dev build"
    echo
}

# Main execution
main() {
    echo
    print_step "Starting GitHub Packages setup..."
    
    check_requirements
    
    echo
    read -p "Do you want to create Kubernetes secret for GitHub Container Registry? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_k8s_secret
    fi
    
    echo
    read -p "Do you want to test image pulls? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_image_pull
    fi
    
    echo
    read -p "Do you want to deploy GitHub Packages manifests to Kubernetes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_to_k8s
    fi
    
    echo
    show_package_info
    
    print_status "GitHub Packages setup completed! 🎉"
}

# Run the script
main "$@"
