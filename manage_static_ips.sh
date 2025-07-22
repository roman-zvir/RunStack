#!/bin/bash

# Static IP Management Script for GCP Deployment
# This script helps manage static IP addresses for the React-Python application

PROJECT_ID="intern-466414"
REGION="us-central1"
FRONTEND_IP_NAME="frontend-static-ip"
BACKEND_IP_NAME="backend-static-ip"
FRONTEND_REPO="us-central1-docker.pkg.dev/intern-466414/my-repo"

function show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  list         List all static IP addresses"
    echo "  create       Create static IP addresses for frontend and backend"
    echo "  delete       Delete static IP addresses"
    echo "  status       Show current deployment status with IPs"
    echo "  update       Update Kubernetes services with static IPs"
    echo "  build        Build and push frontend image to custom repository"
    echo "  help         Show this help message"
}

function list_ips() {
    echo "📋 Listing static IP addresses in region $REGION:"
    gcloud compute addresses list --filter="region:$REGION" --format="table(name,address,status)"
}

function create_ips() {
    echo "🔧 Creating static IP addresses..."
    
    echo "Creating frontend static IP..."
    gcloud compute addresses create $FRONTEND_IP_NAME --region=$REGION
    
    echo "Creating backend static IP..."
    gcloud compute addresses create $BACKEND_IP_NAME --region=$REGION
    
    echo "✅ Static IP addresses created successfully!"
    list_ips
}

function delete_ips() {
    echo "⚠️  WARNING: This will delete static IP addresses!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Deleting static IP addresses..."
        gcloud compute addresses delete $FRONTEND_IP_NAME --region=$REGION --quiet
        gcloud compute addresses delete $BACKEND_IP_NAME --region=$REGION --quiet
        echo "✅ Static IP addresses deleted successfully!"
    else
        echo "❌ Operation cancelled."
    fi
}

function show_status() {
    echo "📊 Current deployment status:"
    echo ""
    echo "Static IP Addresses:"
    list_ips
    echo ""
    echo "Kubernetes Services:"
    kubectl get services -o wide
    echo ""
    echo "Application URLs:"
    FRONTEND_IP=$(gcloud compute addresses describe $FRONTEND_IP_NAME --region=$REGION --format="value(address)" 2>/dev/null)
    BACKEND_IP=$(gcloud compute addresses describe $BACKEND_IP_NAME --region=$REGION --format="value(address)" 2>/dev/null)
    
    if [ ! -z "$FRONTEND_IP" ]; then
        echo "Frontend: http://$FRONTEND_IP"
    fi
    if [ ! -z "$BACKEND_IP" ]; then
        echo "Backend API: http://$BACKEND_IP/api/products"
    fi
}

function build_frontend() {
    echo "🔨 Building and pushing frontend image to $FRONTEND_REPO..."
    
    # Get the static IP addresses to update configuration
    BACKEND_IP=$(gcloud compute addresses describe $BACKEND_IP_NAME --region=$REGION --format="value(address)" 2>/dev/null)
    
    if [ -z "$BACKEND_IP" ]; then
        echo "⚠️  Warning: Backend static IP not found. Using placeholder."
        BACKEND_IP="BACKEND_IP_PLACEHOLDER"
    fi
    
    echo "Using backend IP: $BACKEND_IP"
    
    # Navigate to frontend directory
    cd frontend || { echo "❌ Error: frontend directory not found"; exit 1; }
    
    # Clean and rebuild
    echo "Cleaning previous build..."
    rm -rf build
    
    echo "Building frontend..."
    npm run build
    
    echo "Building Docker image..."
    docker build -t $FRONTEND_REPO/frontend:latest .
    
    echo "Pushing to repository..."
    docker push $FRONTEND_REPO/frontend:latest
    
    echo "✅ Frontend image built and pushed successfully!"
    
    # Return to original directory
    cd ..
}

function update_services() {
    echo "🔄 Updating Kubernetes services with static IPs..."
    
    # Get the static IP addresses
    FRONTEND_IP=$(gcloud compute addresses describe $FRONTEND_IP_NAME --region=$REGION --format="value(address)")
    BACKEND_IP=$(gcloud compute addresses describe $BACKEND_IP_NAME --region=$REGION --format="value(address)")
    
    if [ -z "$FRONTEND_IP" ] || [ -z "$BACKEND_IP" ]; then
        echo "❌ Error: Static IP addresses not found. Please create them first."
        exit 1
    fi
    
    echo "Frontend IP: $FRONTEND_IP"
    echo "Backend IP: $BACKEND_IP"
    
    # Apply the updated service configurations
    kubectl apply -f k8s/frontend-service.yaml
    kubectl apply -f k8s/backend-service.yaml
    
    # Update frontend environment variable and image
    kubectl set env deployment/frontend REACT_APP_BASE_URL=http://$BACKEND_IP/api
    kubectl set image deployment/frontend frontend=$FRONTEND_REPO/frontend:latest
    
    echo "✅ Services updated successfully!"
    echo "Waiting for services to be ready..."
    sleep 10
    show_status
}

# Main script logic
case "${1:-help}" in
    list)
        list_ips
        ;;
    create)
        create_ips
        ;;
    delete)
        delete_ips
        ;;
    status)
        show_status
        ;;
    update)
        update_services
        ;;
    build)
        build_frontend
        ;;
    help|*)
        show_help
        ;;
esac
