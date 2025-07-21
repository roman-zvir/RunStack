# 🚀 React-Python-Playground Makefile
# Simple commands for development and deployment

.PHONY: help install build test lint clean deploy-local deploy-prod

# Default target
help: ## Show this help message
	@echo "🚀 React-Python-Playground Commands"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Installation commands
install: ## Install all dependencies (frontend & backend)
	@echo "📦 Installing backend dependencies..."
	cd backend && pip install -r requirements.txt
	@echo "📦 Installing frontend dependencies..."
	cd frontend && npm install
	@echo "✅ All dependencies installed!"

install-backend: ## Install only backend dependencies
	@echo "📦 Installing backend dependencies..."
	cd backend && pip install -r requirements.txt

install-frontend: ## Install only frontend dependencies
	@echo "📦 Installing frontend dependencies..."
	cd frontend && npm install

# Development commands
dev-backend: ## Start backend development server
	@echo "🚀 Starting backend server..."
	cd backend && python app.py --host 0.0.0.0 --port 5000

dev-frontend: ## Start frontend development server
	@echo "🚀 Starting frontend server..."
	cd frontend && npm start

dev: ## Start both frontend and backend (requires 2 terminals)
	@echo "🚀 Start backend with: make dev-backend"
	@echo "🚀 Start frontend with: make dev-frontend"

# Build commands
build: build-backend build-frontend ## Build both frontend and backend

build-backend: ## Build backend Docker image
	@echo "🐳 Building backend Docker image..."
	cd backend && docker build -t myapp-backend:latest .

build-frontend: ## Build frontend for production
	@echo "🏗️ Building frontend..."
	cd frontend && npm run build

build-frontend-docker: ## Build frontend Docker image
	@echo "🐳 Building frontend Docker image..."
	cd frontend && docker build -t myapp-frontend:latest .

# Testing commands
test: test-backend test-frontend ## Run all tests

test-backend: ## Run backend tests
	@echo "🧪 Running backend tests..."
	cd backend && python -m pytest --cov=. --cov-report=term-missing

test-frontend: ## Run frontend tests
	@echo "🧪 Running frontend tests..."
	cd frontend && npm test -- --coverage --watchAll=false

test-watch-backend: ## Run backend tests in watch mode
	@echo "🧪 Running backend tests in watch mode..."
	cd backend && python -m pytest --cov=. -f

test-watch-frontend: ## Run frontend tests in watch mode
	@echo "🧪 Running frontend tests in watch mode..."
	cd frontend && npm test

# Linting and formatting
lint: lint-backend lint-frontend ## Lint all code

lint-backend: ## Lint backend code
	@echo "🔍 Linting backend..."
	cd backend && flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	cd backend && black --check --diff .

lint-frontend: ## Lint frontend code
	@echo "🔍 Linting frontend..."
	cd frontend && npm run lint

format: ## Format all code
	@echo "🎨 Formatting backend code..."
	cd backend && black .
	@echo "🎨 Formatting frontend code..."
	cd frontend && npm run lint:fix

# Security checks
security: ## Run security checks
	@echo "🔒 Running security checks..."
	cd backend && bandit -r . || true
	cd backend && safety check || true

# Database commands
db-reset: ## Reset the database
	@echo "🗄️ Resetting database..."
	cd backend && rm -f products.db
	@echo "✅ Database reset!"

# Docker commands
docker-build: build-backend build-frontend-docker ## Build all Docker images

docker-run: ## Run the application with Docker
	@echo "🐳 Running with Docker..."
	docker run -d -p 5000:5000 --name backend myapp-backend:latest
	docker run -d -p 3000:3000 --name frontend myapp-frontend:latest
	@echo "✅ Application running at:"
	@echo "   Frontend: http://localhost:3000"
	@echo "   Backend:  http://localhost:5000"

docker-stop: ## Stop Docker containers
	@echo "🛑 Stopping Docker containers..."
	docker stop frontend backend || true
	docker rm frontend backend || true

# Deployment commands
deploy-local: docker-build docker-stop docker-run ## Deploy locally with Docker

deploy-gcp: ## Deploy to Google Cloud Platform
	@echo "🚀 Deploying to GCP..."
	./deploy.sh

# Cleanup commands
clean: ## Clean build artifacts and cache
	@echo "🧹 Cleaning build artifacts..."
	rm -rf frontend/build/
	rm -rf frontend/node_modules/.cache/
	cd backend && find . -name "*.pyc" -delete
	cd backend && find . -name "__pycache__" -type d -exec rm -rf {} + || true
	@echo "✅ Cleanup complete!"

clean-all: clean docker-stop ## Clean everything including Docker containers
	@echo "🧹 Deep cleaning..."
	rm -rf frontend/node_modules/
	cd backend && rm -rf .pytest_cache/
	docker system prune -f || true

# Health checks
health: ## Check application health
	@echo "🏥 Checking application health..."
	@curl -f http://localhost:5000/health || echo "❌ Backend not responding"
	@curl -f http://localhost:3000 || echo "❌ Frontend not responding"

# Show status
status: ## Show current application status
	@echo "📊 Application Status"
	@echo "===================="
	@echo "Backend processes:"
	@ps aux | grep "python.*app.py" | grep -v grep || echo "❌ Backend not running"
	@echo ""
	@echo "Frontend processes:"
	@ps aux | grep "npm.*start" | grep -v grep || echo "❌ Frontend not running"
	@echo ""
	@echo "Docker containers:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "❌ Docker not available"

# Quick setup for new developers
setup: install build test ## Complete setup for new developers
	@echo ""
	@echo "🎉 Setup complete! You can now:"
	@echo "   make dev-backend  # Start backend"
	@echo "   make dev-frontend # Start frontend"
	@echo "   make test         # Run tests"
	@echo "   make help         # See all commands"
