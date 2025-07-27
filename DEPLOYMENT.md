# Branch-Based Deployment Strategy

This project uses a branch-based deployment strategy with separate cloud registries for different environments.

## Repository Structure

- **Development**: `dev-repo` in Google Artifact Registry
- **Production**: `prod-repo` in Google Artifact Registry

## Automated Deployments

### GitHub Actions CI/CD

The GitHub Actions workflow automatically detects the branch and pushes to the appropriate repository:

- **`dev` or `Dev` branch** → pushes to `dev-repo`
- **`main` branch** → pushes to `prod-repo`
- **Other branches** → pushes to `dev-repo` (default)

### Image Tagging Strategy

Images are tagged with multiple tags for better versioning:

**Development (dev-repo):**
- `latest`
- `dev-latest`
- `{commit-sha}`

**Production (prod-repo):**
- `latest`
- `prod-latest`
- `{commit-sha}`
- `v{timestamp}` (e.g., `v20250127-143022`)

## Manual Deployments

### Quick Deployment

Use the smart deployment script that auto-detects your branch:

```bash
./deploy.sh
```

### Specific Environment Deployments

Deploy to development environment:
```bash
./deploy-dev.sh
```

Deploy to production environment:
```bash
./deploy-prod.sh
```

## Environment Configuration

### Development Environment
- **Repository**: `us-central1-docker.pkg.dev/intern-466414/dev-repo`
- **Replicas**: 1 (backend), 1 (frontend)
- **Flask Environment**: `development`
- **Flask Debug**: `true`
- **Domain**: `https://dev.roman-zvir-pet-project.pp.ua` (configure as needed)

### Production Environment
- **Repository**: `us-central1-docker.pkg.dev/intern-466414/prod-repo`
- **Replicas**: 2 (backend), 2 (frontend)
- **Flask Environment**: `production`
- **Flask Debug**: `false`
- **Domain**: `https://roman-zvir-pet-project.pp.ua`

## Repository Setup

The deployment scripts automatically create the required repositories if they don't exist:

```bash
# Development repository
gcloud artifacts repositories create dev-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Development environment container registry"

# Production repository
gcloud artifacts repositories create prod-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Production environment container registry"
```

## Kubernetes Configurations

Environment-specific Kubernetes configurations are stored in:
- `k8s/dev/` - Development environment configs
- `k8s/prod/` - Production environment configs
- `k8s/` - Shared configs (services, ingress, SSL certificates)

## Best Practices

1. **Development Workflow**:
   - Work on feature branches
   - Push to `dev` branch for testing
   - Create pull requests to `main` for production releases

2. **Production Releases**:
   - Only deploy to `main` branch after thorough testing
   - Production deployments are automatically tagged with timestamps
   - Multiple replicas ensure high availability

3. **Repository Isolation**:
   - Development and production images are completely isolated
   - No risk of accidentally deploying dev images to production
   - Clear separation of concerns

## Monitoring

Check deployment status:

```bash
# Check running pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# Check ingress
kubectl get ingress
```

## Troubleshooting

If you encounter authentication issues:

```bash
# Authenticate with gcloud
gcloud auth login

# Configure Docker for Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Get cluster credentials
gcloud container clusters get-credentials react-python-cluster --zone=us-central1-a
```
