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

# Detect current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

print_status "Detected branch: $CURRENT_BRANCH"

# Determine which deployment script to use
if [[ "$CURRENT_BRANCH" == "main" ]]; then
    print_status "🚀 Deploying to PRODUCTION environment..."
    ./deploy-prod.sh
elif [[ "$CURRENT_BRANCH" == "dev" || "$CURRENT_BRANCH" == "Dev" ]]; then
    print_status "🚀 Deploying to DEVELOPMENT environment..."
    ./deploy-dev.sh
else
    print_warning "Branch '$CURRENT_BRANCH' detected."
    print_status "Available options:"
    echo "  1) Deploy to DEV environment (recommended for feature branches)"
    echo "  2) Deploy to PROD environment (use with caution!)"
    echo "  3) Cancel"
    
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            print_status "🚀 Deploying to DEVELOPMENT environment..."
            ./deploy-dev.sh
            ;;
        2)
            print_warning "⚠️  You are about to deploy to PRODUCTION from branch '$CURRENT_BRANCH'"
            read -p "Are you sure? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                print_status "🚀 Deploying to PRODUCTION environment..."
                ./deploy-prod.sh
            else
                print_status "Deployment cancelled."
                exit 0
            fi
            ;;
        3|*)
            print_status "Deployment cancelled."
            exit 0
            ;;
    esac
fi

print_success "🎉 Deployment completed!"