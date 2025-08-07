# GitHub Packages Integration

This document explains how the GitHub Packages integration works for the React Python Playground project.

## Overview

The project uses a **mirror strategy** where:
1. **Azure Container Registry** is the primary source for production images
2. **GitHub Packages** serves as a mirror/distribution point for these production images

## Workflow Architecture

### 1. Main CI/CD Pipeline (`.github/workflows/ci.yml`)
- **Triggers**: Push to `main` branch only
- **Purpose**: Builds and pushes **production images** to Azure Container Registry
- **Images built**:
  - `runstackregistry.azurecr.io/backend-prod:latest`
  - `runstackregistry.azurecr.io/frontend-prod:latest`
- **Uses**: Production Dockerfiles (`Dockerfile.prod`) for optimized builds

### 2. GitHub Packages Mirror (`.github/workflows/github-packages.yml`)
- **Triggers**: Push to `main` branch (after Azure build completes)
- **Purpose**: Pulls production images from Azure and mirrors them to GitHub Packages
- **Process**:
  1. Login to Azure Container Registry
  2. Pull production images from Azure
  3. Re-tag for GitHub Packages
  4. Push to GitHub Container Registry (ghcr.io)

## Image Locations

### Azure Container Registry (Source)
```
runstackregistry.azurecr.io/backend-prod:latest
runstackregistry.azurecr.io/frontend-prod:latest
```

### GitHub Packages (Mirror)
```
ghcr.io/roman-zvir/backend-prod:latest
ghcr.io/roman-zvir/frontend-prod:latest
ghcr.io/roman-zvir/backend-prod:<commit-sha>
ghcr.io/roman-zvir/frontend-prod:<commit-sha>
```

## Kubernetes Deployment

### Azure Images (Primary)
Use your existing Kubernetes manifests in `k8s/prod/` that reference Azure images.

### GitHub Packages Images (Alternative)
Use the manifests in `k8s/github-packages/` that reference GitHub Packages:
- `frontend-deployment.yaml` - Uses `ghcr.io/roman-zvir/frontend-prod:latest`
- `backend-deployment.yaml` - Uses `ghcr.io/roman-zvir/backend-prod:latest`

## Setup Instructions

### 1. GitHub Packages Authentication
Run the setup script:
```bash
./scripts/setup-github-packages.sh
```

This will:
- Create Kubernetes secret for GitHub Container Registry authentication
- Test image pulling capabilities
- Deploy GitHub Packages manifests (optional)

### 2. Manual Kubernetes Secret Creation
If you prefer manual setup:
```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<your-github-username> \
  --docker-password=<your-github-token> \
  --docker-email=<your-email>
```

**Required Token Permissions:**
- `packages:read` - To pull images
- `packages:write` - If you need to push (handled by workflows)

### 3. Deploy Using GitHub Packages
```bash
kubectl apply -f k8s/github-packages/
```

## Workflow Triggers

### Automatic Triggers
1. **Push to `main`** → Builds prod images in Azure → Mirrors to GitHub Packages
2. **Manual workflow dispatch** → Can trigger GitHub Packages mirror independently

### Manual Triggers
```bash
# Trigger GitHub Packages mirror manually
gh workflow run github-packages.yml
```

## Benefits of This Approach

1. **Azure as Source of Truth**: Production images are built and stored in your existing Azure infrastructure
2. **GitHub Packages for Distribution**: Easy access and distribution through GitHub's package registry
3. **Flexibility**: Can deploy from either registry as needed
4. **Backup/Redundancy**: Images available in multiple locations
5. **Public Access**: GitHub Packages can provide public access if needed

## Monitoring

### View Packages
- **GitHub UI**: https://github.com/roman-zvir?tab=packages
- **Package Details**: https://github.com/users/roman-zvir/packages/container/backend-prod

### Workflow Status
- Check Actions tab in GitHub repository
- Monitor both CI/CD and GitHub Packages workflows

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify GitHub token has `packages:read` permission
   - Check Kubernetes secret is properly created
   - Ensure Azure credentials are configured

2. **Image Not Found**
   - Verify the main branch workflow completed successfully
   - Check that Azure images exist before mirroring
   - Confirm GitHub Packages workflow ran after Azure build

3. **Pull Errors in Kubernetes**
   - Verify `ghcr-secret` exists in the correct namespace
   - Check image pull secrets are referenced in deployments
   - Confirm image tags are correct

### Debug Commands
```bash
# Check if images exist in GitHub Packages
docker pull ghcr.io/roman-zvir/backend-prod:latest
docker pull ghcr.io/roman-zvir/frontend-prod:latest

# Verify Kubernetes secret
kubectl get secret ghcr-secret -o yaml

# Check pod events for pull errors
kubectl describe pod <pod-name>
```
