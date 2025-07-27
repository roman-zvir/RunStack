#!/usr/bin/env bash

set -e  # Exit on any error

echo "🚀 Starting automated GCP deployment for PRODUCTION environment..."

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

# PRODUCTION environment configuration
PROJECT_ID="intern-466414"
REGISTRY_LOCATION="us-central1-docker.pkg.dev"
PROD_REPOSITORY="prod-repo"  # Separate repository for production
GKE_CLUSTER="react-python-cluster"  # Your existing production cluster
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

# Check if production repository exists, create if it doesn't
print_status "Checking if production repository exists..."
if ! gcloud artifacts repositories describe ${PROD_REPOSITORY} --location=${REGISTRY_LOCATION%%-*} --quiet &> /dev/null; then
    print_warning "Production repository doesn't exist. Creating it..."
    gcloud artifacts repositories create ${PROD_REPOSITORY} \
        --repository-format=docker \
        --location=${REGISTRY_LOCATION%%-*} \
        --description="Production environment container registry"
    print_success "Production repository created"
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
VERSION_TAG="v$(date +%Y%m%d-%H%M%S)"

# Build and push images to Production Artifact Registry
print_status "Building and pushing backend image to PRODUCTION repository..."
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:${VERSION_TAG} ./backend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:${COMMIT_HASH} ./backend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:latest ./backend
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:${VERSION_TAG}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:${COMMIT_HASH}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:latest
print_success "Backend image built and pushed to PRODUCTION repository"

print_status "Building and pushing frontend image to PRODUCTION repository..."
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:${VERSION_TAG} ./frontend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:${COMMIT_HASH} ./frontend
docker build -t ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:latest ./frontend
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:${VERSION_TAG}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:${COMMIT_HASH}
docker push ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:latest
print_success "Frontend image built and pushed to PRODUCTION repository"

# Deploy to GKE using production-specific configurations
print_status "Applying Kubernetes configurations for PRODUCTION environment..."

# Create temporary deployment files with production-specific images
sed "s|us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest|${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:latest|g" k8s/backend-deployment.yaml > /tmp/backend-deployment-prod.yaml
sed "s|us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest|${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:latest|g" k8s/frontend-deployment.yaml > /tmp/frontend-deployment-prod.yaml

# Apply backend deployment first
kubectl apply -f /tmp/backend-deployment-prod.yaml

# Apply frontend deployment
kubectl apply -f /tmp/frontend-deployment-prod.yaml

# Apply services
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml

# Apply SSL certificate and ingress
kubectl apply -f k8s/ssl-certificate.yaml
kubectl apply -f k8s/ingress.yaml

print_status "Updating deployments with new production images..."
kubectl set image deployment/backend backend=${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/backend:latest
kubectl set image deployment/frontend frontend=${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/frontend:latest

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

print_success "PRODUCTION deployment complete!"

echo
echo "🌐 Your PRODUCTION application is accessible via:"
echo "   📱 Domain:    https://roman-zvir-pet-project.pp.ua"
echo "   🔧 Frontend:  http://${FRONTEND_IP}"
echo "   🛠️  Backend:   http://${BACKEND_IP}/api/products"
echo "   🏷️  Version:  ${VERSION_TAG}"
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

print_status "Testing backend API via domain (ingress)..."
if curl -s -k "https://roman-zvir-pet-project.pp.ua/api/health" | grep -q "healthy"; then
    print_success "Backend API is responding via domain"
else
    print_warning "Backend API test failed via domain - ingress might need time to propagate"
    print_status "Testing what domain returns:"
    curl -s -k "https://roman-zvir-pet-project.pp.ua/api/health" | head -50
fi

# Show pod status
print_status "Current pod status:"
kubectl get pods

# Clean up temporary files
rm -f /tmp/backend-deployment-prod.yaml /tmp/frontend-deployment-prod.yaml

echo
print_success "🎉 Automated PRODUCTION deployment completed successfully!"
echo "📝 Images pushed to: ${REGISTRY_LOCATION}/${PROJECT_ID}/${PROD_REPOSITORY}/"
echo "🔖 Tagged with version: ${VERSION_TAG}"
