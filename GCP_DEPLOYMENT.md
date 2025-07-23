# GCP Deployment Guide

## Deployed Application

Your React + Flask application has been successfully deployed to Google Cloud Platform!

### Live URLs
- **Frontend**: http://34.29.235.29 (Static IP)
- **Backend API**: http://34.16.74.187/api/products (Static IP)

✅ **Status**: Both frontend and backend are connected and working correctly!

## Deployment Architecture

- **Platform**: Google Kubernetes Engine (GKE)
- **Cluster**: `react-python-cluster` in `us-central1-a`
- **Container Registry**: Google Container Registry (GCR)
- **Images**: 
  - `gcr.io/intern-466414/frontend:latest`
  - `gcr.io/intern-466414/backend:latest`

## Deployment Commands Summary

### 1. Prerequisites Setup
```bash
# Enable required APIs
gcloud services enable container.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com

# Configure Docker for GCR
gcloud auth configure-docker
```

### 2. Create GKE Cluster
```bash
gcloud container clusters create react-python-cluster \
    --zone=us-central1-a \
    --num-nodes=2 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=3
```

### 3. Build and Push Images
```bash
# Build images
docker build -t gcr.io/intern-466414/backend:latest ./backend
docker build -t gcr.io/intern-466414/frontend:latest ./frontend

# Push to GCR
docker push gcr.io/intern-466414/backend:latest
docker push gcr.io/intern-466414/frontend:latest
```

### 4. Deploy to Kubernetes
```bash
# Get cluster credentials
gcloud container clusters get-credentials react-python-cluster --zone=us-central1-a

# Deploy all manifests
kubectl apply -f k8s/

# Change services to LoadBalancer type
kubectl patch service frontend -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch service backend -p '{"spec":{"type":"LoadBalancer"}}'

# Update frontend environment
kubectl set env deployment/frontend REACT_APP_BASE_URL=http://34.16.74.187/api
```

## Management Commands

### Check Deployment Status
```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

### View Logs
```bash
kubectl logs deployment/frontend
kubectl logs deployment/backend
```

### Scale Deployments
```bash
kubectl scale deployment frontend --replicas=3
kubectl scale deployment backend --replicas=2
```

### Update Images
```bash
# Build new image
docker build -t gcr.io/intern-466414/backend:v2 ./backend
docker push gcr.io/intern-466414/backend:v2

# Update deployment
kubectl set image deployment/backend backend=gcr.io/intern-466414/backend:v2
```

## Static IP Management

### Reserved Static IPs
- **Frontend IP**: 34.29.235.29 (frontend-static-ip)
- **Backend IP**: 34.16.74.187 (backend-static-ip)

### Static IP Commands
```bash
# List reserved static IPs
gcloud compute addresses list --filter="region:us-central1"

# Create new static IP
gcloud compute addresses create <name> --region=us-central1

# Delete static IP (when no longer needed)
gcloud compute addresses delete <name> --region=us-central1
```

### Important Notes
- Static IPs incur charges even when not in use
- Make sure to delete them when shutting down the project to avoid unnecessary costs
- The LoadBalancer services are configured to use these specific IPs

## Cost Optimization

### Delete Resources When Not Needed
```bash
# Delete the cluster (saves the most money)
gcloud container clusters delete react-python-cluster --zone=us-central1-a

# Or scale down to 0 nodes
gcloud container clusters resize react-python-cluster --num-nodes=0 --zone=us-central1-a
```

## Alternative Deployment Options

### 1. Cloud Run (Serverless)
- More cost-effective for low traffic
- Automatic scaling to zero
- Simpler management

### 2. Compute Engine
- Direct VM deployment
- More control over infrastructure
- Manual scaling

### 3. App Engine
- Fully managed platform
- Automatic scaling
- Built-in CI/CD

## Security Considerations

1. **Use HTTPS**: Set up SSL certificates for production
2. **Environment Variables**: Store sensitive data in Kubernetes secrets
3. **Network Policies**: Restrict pod-to-pod communication
4. **Image Security**: Scan images for vulnerabilities

## Monitoring and Logging

- **Google Cloud Logging**: Automatic log collection
- **Google Cloud Monitoring**: Application metrics
- **Kubernetes Dashboard**: Cluster visualization

Your application is now live and accessible from anywhere in the world!
