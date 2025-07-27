#!/usr/bin/env bash

set -e  # Exit on any error

echo "🚀 Starting automated GCP deployment for DEV environment..."

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

# DEV environment configuration
PROJECT_ID="intern-466414"
REGISTRY_LOCATION="us-central1-docker.pkg.dev"
DEV_REPOSITORY="dev-repo"  # Separate repository for dev
GKE_CLUSTER="react-python-cluster-dev"  # You might want a separate dev cluster
GKE_ZONE="us-central1-a"

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
gcloud auth configure-docker ${REGISTRY_LOCATION} --quiet

# Check if dev repository exists, create if it doesn't
print_status "Checking if dev repository exists..."
if ! gcloud artifacts repositories describe ${DEV_REPOSITORY} --location=${REGISTRY_LOCATION%%-*} --quiet &> /dev/null; then
    print_warning "Dev repository doesn't exist. Creating it..."
    gcloud artifacts repositories create ${DEV_REPOSITORY} \
        --repository-format=docker \
        --location=${REGISTRY_LOCATION%%-*} \
        --description="Development environment container registry"
    print_success "Dev repository created"
fi

# Check if cluster exists and is accessible
print_status "Checking GKE cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    print_warning "Cannot connect to Kubernetes cluster. Trying to get credentials..."
    gcloud container clusters get-credentials ${GKE_CLUSTER} --zone=${GKE_ZONE} --quiet
fi

print_success "Connected to GKE cluster"

# Get current git branch or commit hash for tagging
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

# Build and push images to Dev Artifact Registry
print_status "Building and pushing backend image to DEV repository..."
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:${BRANCH_NAME}-${COMMIT_HASH} ./backend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:dev-latest ./backend
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:${BRANCH_NAME}-${COMMIT_HASH}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:dev-latest
print_success "Backend image built and pushed to DEV repository"

print_status "Building and pushing frontend image to DEV repository..."
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:${BRANCH_NAME}-${COMMIT_HASH} ./frontend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:dev-latest ./frontend
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:${BRANCH_NAME}-${COMMIT_HASH}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:dev-latest
print_success "Frontend image built and pushed to DEV repository"

# Deploy to GKE using dev-specific configurations
print_status "Applying Kubernetes configurations for DEV environment..."

# Create temporary deployment files with dev-specific images
sed "s|us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest|${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:dev-latest|g" k8s/backend-deployment.yaml > /tmp/backend-deployment-dev.yaml
sed "s|us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest|${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:dev-latest|g" k8s/frontend-deployment.yaml > /tmp/frontend-deployment-dev.yaml

# Apply backend deployment first
kubectl apply -f /tmp/backend-deployment-dev.yaml

# Apply frontend deployment
kubectl apply -f /tmp/frontend-deployment-dev.yaml

# Apply services (these don't need to change)
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml

# Apply SSL certificate and ingress (you might want dev-specific ingress)
kubectl apply -f k8s/ssl-certificate.yaml
kubectl apply -f k8s/ingress.yaml

print_status "Updating deployments with new dev images..."
kubectl set image deployment/backend backend=${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/backend:dev-latest
kubectl set image deployment/frontend frontend=${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/frontend:dev-latest

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

print_success "DEV deployment complete!"

echo
echo "🌐 Your DEV application is accessible via:"
echo "   📱 Domain:    https://dev.roman-zvir-pet-project.pp.ua (configure your dev domain)"
echo "   🔧 Frontend:  http://${FRONTEND_IP}"
echo "   🛠️  Backend:   http://${BACKEND_IP}/api/products"
echo "   🏷️  Tag:      ${BRANCH_NAME}-${COMMIT_HASH}"
echo
echo "📊 Ingress Status:"
kubectl get ingress app-ingress
echo

# Test the deployment
print_status "Testing backend API via LoadBalancer..."
if curl -s "http://${BACKEND_IP}:5000/api/products" > /dev/null; then
    print_success "Backend API is responding via LoadBalancer"
else
    print_warning "Backend API test failed via LoadBalancer - it might need a moment to start"
fi

# Show pod status
print_status "Current pod status:"
kubectl get pods

# Clean up temporary files
rm -f /tmp/backend-deployment-dev.yaml /tmp/frontend-deployment-dev.yaml

echo
print_success "🎉 Automated DEV deployment completed successfully!"
echo "📝 Images pushed to: ${REGISTRY_LOCATION}/${PROJECT_ID}/${DEV_REPOSITORY}/"
