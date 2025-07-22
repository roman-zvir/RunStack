#!/bin/bash

# Domain deployment script
set -e

echo "🚀 Setting up domain for React-Python application"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if domain is provided
if [ -z "$1" ]; then
    print_error "Please provide your domain name as an argument"
    echo "Usage: $0 <your-domain.com>"
    exit 1
fi

DOMAIN=$1
WWW_DOMAIN="www.$DOMAIN"

print_status "Setting up domain: $DOMAIN"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    print_warning "gcloud is not installed. You'll need to reserve static IP manually"
else
    print_status "Reserving static IP address..."
    if gcloud compute addresses create app-static-ip --global --quiet; then
        print_status "Static IP reserved successfully"
    else
        print_warning "Static IP might already exist or failed to create"
    fi
    
    # Get the static IP
    STATIC_IP=$(gcloud compute addresses describe app-static-ip --global --format="value(address)" 2>/dev/null || echo "")
    if [ -n "$STATIC_IP" ]; then
        print_status "Static IP address: $STATIC_IP"
        print_warning "Please update your DNS records:"
        echo "  A Record: $DOMAIN → $STATIC_IP"
        echo "  A Record: $WWW_DOMAIN → $STATIC_IP"
    fi
fi

# Update ingress.yaml with the actual domain
print_status "Updating ingress configuration..."
sed -i "s/your-domain\.com/$DOMAIN/g" k8s/ingress.yaml

# Update frontend deployment with the actual domain
print_status "Updating frontend configuration..."
sed -i "s/your-domain\.com/$DOMAIN/g" k8s/frontend-deployment.yaml

# Apply Kubernetes configurations
print_status "Applying Kubernetes configurations..."

# Apply services first
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/backend-service.yaml

# Apply deployments
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml

# Apply ingress
kubectl apply -f k8s/ingress.yaml

# Wait for ingress to get an IP
print_status "Waiting for ingress to get an external IP..."
for i in {1..30}; do
    INGRESS_IP=$(kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$INGRESS_IP" ]; then
        print_status "Ingress IP assigned: $INGRESS_IP"
        break
    fi
    echo -n "."
    sleep 10
done

if [ -z "$INGRESS_IP" ]; then
    print_warning "Ingress IP not assigned yet. Check with: kubectl get ingress app-ingress"
fi

# Check pod status
print_status "Checking pod status..."
kubectl get pods -l app=frontend
kubectl get pods -l app=backend

print_status "Domain setup complete!"
print_warning "Next steps:"
echo "1. Update your DNS records if not done already"
echo "2. Wait for DNS propagation (up to 48 hours)"
echo "3. Set up SSL certificate (see DOMAIN_SETUP.md for details)"
echo "4. Test your application at https://$DOMAIN"

print_status "Useful commands:"
echo "  Check ingress status: kubectl get ingress app-ingress"
echo "  Check pods: kubectl get pods"
echo "  View logs: kubectl logs -l app=frontend"
