#!/usr/bin/env bash

set -e  # Exit on any error

echo "🚀 Starting automated GCP deployment..."

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

# Check if required tools are installed
print_status "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed!"
    exit 1
fi

if ! command -v gcloud &> /dev/null; then
    print_error "gcloud is not installed!"
    exit 1
fi

print_success "All prerequisites are installed"

# Check if authenticated with gcloud
print_status "Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null; then
    print_warning "Not authenticated with gcloud. Please run: gcloud auth login"
    exit 1
fi

print_success "Authenticated with gcloud"

# Configure Docker for Artifact Registry if not already configured
print_status "Configuring Docker for Artifact Registry..."
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

# Check if cluster exists and is accessible
print_status "Checking GKE cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    print_warning "Cannot connect to Kubernetes cluster. Trying to get credentials..."
    gcloud container clusters get-credentials react-python-cluster --zone=us-central1-a --quiet
fi

print_success "Connected to GKE cluster"

# Build and push images to Artifact Registry
print_status "Building and pushing backend image..."
docker build -t us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest ./backend
docker push us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest
print_success "Backend image built and pushed"

print_status "Building and pushing frontend image..."
docker build -t us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest ./frontend
docker push us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest
print_success "Frontend image built and pushed"

# Deploy to GKE
print_status "Updating deployments..."
kubectl set image deployment/backend backend=us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest
kubectl set image deployment/frontend frontend=us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest

print_status "Waiting for rollout to complete..."
kubectl rollout status deployment/backend --timeout=300s
kubectl rollout status deployment/frontend --timeout=300s

# Get service IPs
print_status "Getting service information..."
FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
BACKEND_IP=$(kubectl get service backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

# Wait for external IPs if they're pending
if [[ "$FRONTEND_IP" == "pending" ]] || [[ "$BACKEND_IP" == "pending" ]]; then
    print_warning "External IPs are still being assigned. Waiting up to 2 minutes..."
    
    for i in {1..24}; do
        sleep 5
        FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
        BACKEND_IP=$(kubectl get service backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
        
        if [[ "$FRONTEND_IP" != "pending" ]] && [[ "$BACKEND_IP" != "pending" ]]; then
            break
        fi
        
        echo -n "."
    done
    echo
fi

print_success "Deployment complete!"

echo
echo "🌐 Your application is live:"
echo "   Frontend: http://${FRONTEND_IP}:3000"
echo "   Backend:  http://${BACKEND_IP}:5000/api/products"
echo

# Test the deployment
print_status "Testing backend API..."
if curl -s "http://${BACKEND_IP}:5000/api/products" > /dev/null; then
    print_success "Backend API is responding"
else
    print_warning "Backend API test failed - it might need a moment to start"
fi

# Show pod status
print_status "Current pod status:"
kubectl get pods

echo
print_success "🎉 Automated deployment completed successfully!"