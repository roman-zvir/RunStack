# 🚀 CI/CD Setup Guide

This guide explains how to set up and use the comprehensive CI/CD pipeline for your React-Python playground.

## 🔧 What's Included

### ✅ **Automated CI/CD Pipeline** (`ci.yml`)
- **Frontend Testing**: Jest, React Testing Library
- **Backend Testing**: pytest with coverage
- **Code Quality**: ESLint, flake8, black
- **Security**: bandit, safety, Trivy scanning
- **Docker**: Build and push images
- **Deployment**: Automated GCP deployment

### 🛠️ **Developer Tools**
- **Makefile**: 20+ useful commands
- **Health Checks**: `/health` endpoint
- **Test Coverage**: Automated reporting
- **Code Formatting**: Automated checks

## 🚀 Quick Start

### 1. **Install Dependencies**
```bash
# Install everything
make install

# Or install separately
make install-frontend  # Frontend only
make install-backend   # Backend only
```

### 2. **Run Tests**
```bash
# Run all tests
make test

# Run frontend tests only
make test-frontend

# Run backend tests only  
make test-backend

# Run tests in watch mode
make test-watch-frontend
make test-watch-backend
```

### 3. **Check Code Quality**
```bash
# Lint all code
make lint

# Format all code
make format

# Security checks
make security
```

### 4. **Build & Run**
```bash
# Build everything
make build

# Run locally with Docker
make deploy-local

# Health check
make health
```

## 📋 Available Commands

Run `make help` to see all available commands:

```bash
make help
```

Key commands:
- `make setup` - Complete setup for new developers
- `make dev-backend` - Start backend server
- `make dev-frontend` - Start frontend server
- `make docker-build` - Build Docker images
- `make clean` - Clean build artifacts
- `make status` - Show application status

## 🔐 CI/CD Configuration

### **GitHub Secrets** (Optional)
To enable full CI/CD features, add these secrets to your GitHub repository:

#### Docker Hub (for image publishing)
- `DOCKER_USERNAME` - Your Docker Hub username
- `DOCKER_PASSWORD` - Your Docker Hub password/token

#### Google Cloud Platform (for deployment)
- `GCP_SA_KEY` - Service account JSON key
- `GKE_CLUSTER` - Your GKE cluster name
- `GKE_ZONE` - Your GKE cluster zone
- `GCP_PROJECT` - Your GCP project ID

### **Current Status**
🔄 **Currently Configured**: Testing, linting, security scanning, Docker building
⏸️ **Temporarily Disabled**: Docker Hub push, GCP deployment, Trivy scanning

*These are disabled until you configure the required secrets.*

## 🔄 Pipeline Triggers

The CI/CD pipeline runs automatically on:
- **Push** to `main`, `dev`, or `Dev` branches
- **Pull requests** to `main`, `dev`, or `Dev` branches
- **Manual dispatch** (GitHub Actions tab)

## 📊 Pipeline Jobs

### 1. **Frontend Jobs**
- **frontend-test**: Runs tests with coverage
- **frontend-lint**: ESLint code quality checks

### 2. **Backend Jobs**  
- **backend-test**: pytest, flake8, black, bandit, safety

### 3. **Docker Jobs**
- **docker-build**: Build images with security scanning

### 4. **Deployment Jobs**
- **deploy**: Automated GCP deployment (when enabled)

### 5. **Notification Jobs**
- **notify**: Pipeline summary and status

## 🛡️ Security Features

- **Dependency Scanning**: safety (Python), npm audit (Node.js)
- **Code Security**: bandit for Python security issues
- **Container Security**: Trivy vulnerability scanning
- **SARIF Reports**: Uploaded to GitHub Security tab

## 📈 Coverage Reports

Test coverage is automatically:
- Calculated during test runs
- Reported in pull requests
- Uploaded to Codecov (when configured)
- Available in CI artifacts

## 🐛 Troubleshooting

### **Common Issues**

1. **`npm ci` fails with "Dependencies lock file is not found"**
   ```bash
   # This indicates a cache path issue in CI/CD
   # Fixed by adding cache-dependency-path: './frontend/package-lock.json'
   # in the GitHub Actions workflow
   ```

2. **`npm ci` fails with missing packages**
   ```bash
   cd frontend && npm install  # Regenerate package-lock.json
   ```

3. **Python tests fail**
   ```bash
   cd backend && python -m pytest -v  # Detailed test output
   ```

4. **Docker build fails**
   ```bash
   make docker-build  # Local build test
   ```

5. **Linting errors**
   ```bash
   make format  # Auto-fix formatting issues
   ```

### **Enable Full Features**

To enable Docker Hub integration:
1. Add `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
2. Change `push: false` to `push: ${{ github.ref == 'refs/heads/main' }}` in `ci.yml`
3. Change `if: false` to `if: github.ref == 'refs/heads/main'` for Docker login

To enable GCP deployment:
1. Add GCP secrets (see above)
2. Change `if: false` to `if: github.ref == 'refs/heads/main' && github.event_name == 'push'` for deploy job

## 🎯 Next Steps

1. **Test the Pipeline**: Make a small commit and push to see it run
2. **Add Secrets**: Configure Docker Hub and GCP secrets for full features
3. **Customize**: Modify the pipeline for your specific needs
4. **Monitor**: Check the Actions tab for pipeline results

## 📝 Files Added/Modified

- `.github/workflows/ci.yml` - Main CI/CD pipeline
- `Makefile` - Developer commands
- `backend/test_app.py` - Backend tests
- `backend/requirements.txt` - Testing dependencies
- `backend/.coveragerc` - Coverage configuration
- `backend/pytest.ini` - pytest configuration
- `frontend/package.json` - Testing dependencies and scripts
- `frontend/src/setupTests.js` - Jest configuration
- `frontend/src/components/__tests__/ProductList.test.tsx` - Frontend tests

---

**Happy coding! 🚀** Your CI/CD pipeline is ready to ensure code quality and automate deployments!
