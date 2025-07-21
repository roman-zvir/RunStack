# 🐳 Migration to Google Artifact Registry

## Problem
The CI/CD pipeline is failing with permission errors when trying to push Docker images to Google Container Registry (GCR). This is because Google has deprecated GCR in favor of Artifact Registry.

## Error Message
```
denied: Permission "artifactregistry.repositories.uploadArtifacts" denied on resource "projects/intern-466414/locations/us/repositories/gcr.io" (or it may not exist)
```

## Solution Steps

### 1. Create Artifact Registry Repository
First, you need to create an Artifact Registry repository in your GCP project:

```bash
# Set your project
gcloud config set project intern-466414

# Create an Artifact Registry repository
gcloud artifacts repositories create my-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository for react-python-playground"
```

### 2. Update Service Account Permissions
Your service account needs the following roles:
- `roles/artifactregistry.writer` (to push images)
- `roles/artifactregistry.reader` (to pull images)

```bash
# Get your service account email (replace with your actual SA email)
SA_EMAIL="your-service-account@intern-466414.iam.gserviceaccount.com"

# Grant Artifact Registry permissions
gcloud projects add-iam-policy-binding intern-466414 \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding intern-466414 \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/artifactregistry.reader"
```

### 3. Update CI/CD Environment Variables
The workflow has been updated to use:
- `ARTIFACT_REGISTRY`: `us-central1-docker.pkg.dev`
- `REPOSITORY_NAME`: `my-repo`

### 4. Update Kubernetes Manifests
Update your Kubernetes deployment files to use the new registry:

#### Backend Deployment
```yaml
# k8s/backend-deployment.yaml
spec:
  template:
    spec:
      containers:
        - name: backend
          image: us-central1-docker.pkg.dev/intern-466414/my-repo/backend:latest
```

#### Frontend Deployment
```yaml
# k8s/frontend-deployment.yaml
spec:
  template:
    spec:
      containers:
        - name: frontend
          image: us-central1-docker.pkg.dev/intern-466414/my-repo/frontend:latest
```

### 5. Manual Testing
Test the new setup locally:

```bash
# Authenticate Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build and push test image
docker build -t us-central1-docker.pkg.dev/intern-466414/my-repo/backend:test ./backend
docker push us-central1-docker.pkg.dev/intern-466414/my-repo/backend:test
```

## Configuration Changes Made

### CI/CD Workflow Updates
1. ✅ Updated environment variables to use Artifact Registry
2. ✅ Changed Docker authentication command
3. ✅ Updated image build and push commands
4. ✅ Modified deployment script to use new registry

### Required Actions
- [ ] Create Artifact Registry repository (`my-repo`)
- [ ] Update service account permissions
- [ ] Update Kubernetes deployment files
- [ ] Test the pipeline

## Alternative: Use Different Repository Name
If you prefer a different repository name, update the `REPOSITORY_NAME` environment variable in the CI/CD workflow and adjust all references accordingly.

## Rollback Plan
If issues arise, you can temporarily revert to GCR by:
1. Reverting the workflow changes
2. Ensuring your service account has `roles/storage.admin` for GCR access
3. Using `gcloud auth configure-docker` without the registry URL
