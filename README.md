
<div align="center">
  <h1>🚀 RunStack</h1>
  <p>A modern full‑stack web app template (React + Flask) with Docker, CI/CD, and Kubernetes</p>

  <a href="https://runstack.pp.ua/"><img alt="Live Demo" src="https://img.shields.io/badge/demo-live-green.svg"></a>
  <a href="https://opensource.org/licenses/MIT"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
  <a href="https://hub.docker.com/u/romanzvir"><img alt="Docker" src="https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white"></a>
  <a href="https://github.com/roman-zvir/RunStack/actions"><img alt="CI/CD" src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white"></a>

  <a href="https://runstack.pp.ua/">Live Demo</a> • <a href="https://runstack.pp.ua/api/products">API</a> • <a href="https://github.com/roman-zvir/RunStack/issues">Issues</a>
</div>



## 🖥️ Screenshots

### 📌 Main Page

<div align="center">
  <img src="https://github.com/user-attachments/assets/6850b394-e7e5-463d-b6cd-6aefdbdf79a4" alt="Main Page" width="80%" />
</div>

Browse products in a clean, responsive UI.

---

### ✏️ Add/Edit Product

<div align="center">
  <img src="https://github.com/user-attachments/assets/4e31bc77-567d-4c1e-8159-298960b49dd9" alt="Add or Edit Product" width="80%" />
</div>

Create and update products with simple validation.





## 🎯 About



RunStack is a production‑ready full‑stack template showing modern dev practices: containerization, CI/CD, and cloud deployment. It uses a React frontend and a Flask REST API backend, deploys to Microsoft Azure AKS, and serves a custom domain with HTTPS.


### ✨ Key Highlights

- **🔄 Full‑Stack**: React frontend with Flask REST API backend
- **🐳 Containerized**: Docker-ready for any environment
- **☁️ Cloud Native**: Deployed on Microsoft Azure with Azure Kubernetes Service (AKS)
- **🌐 Custom Domain**: Available at https://runstack.pp.ua/
- **🔒 SSL Secured**: HTTPS enabled with SSL certificate
- **🚀 CI/CD**: Automated builds and deployments with GitHub Actions
- **📱 Responsive**: Mobile-first design with Bulma CSS framework
- **🏆 Production Ready**: Includes security, logging, and monitoring

## 🛠 Tech Stack

### Frontend
- React 18, React Router 6
- Axios for API calls
- Bulma CSS
- Create React App build tooling

### Backend
- Flask 2.2 + Flask‑RESTful, Flask‑CORS
- Peewee ORM, SQLite (local)

### DevOps & Infrastructure
- Docker, Kubernetes (AKS)
- GitHub Actions CI/CD
- Azure Container Registry (ACR), Docker Hub

## ✨ Features

- 🎯 **Product Management**: Full CRUD operations for products
- 🔍 **Search & Filter**: Real-time product search
- 📱 **Responsive Design**: Works on all device sizes
- 🔄 **Real-time Updates**: Instant UI updates
- 🐳 **Containerized**: Ready for any deployment environment
- 🚀 **Auto-Deploy**: Push to deploy with GitHub Actions
- ☁️ **Cloud Ready**: Kubernetes manifests included
- 📊 **Monitoring**: Health checks and logging
- 🔒 **Secure**: CORS enabled and input validation

## 🚀 Quick Start

### Prerequisites
- Docker (optional)
- Node.js 18+
- Python 3.11+
- Git

### Clone
```bash
git clone https://github.com/roman-zvir/RunStack.git
cd RunStack
```

### Option A: Makefile (recommended)
```bash
# One‑time: create virtualenv at repo root for Makefile helpers
python3 -m venv .venv

# Install deps (backend + frontend)
make install

# Run dev servers (use 2 terminals)
make dev-backend   # http://localhost:5000
make dev-frontend  # http://localhost:3000
```

### Option B: Manual
```bash
# Backend
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python app.py --host 0.0.0.0 --port 5000
```

```bash
# Frontend (new terminal)
cd frontend
npm install
npm start
```

### Option C: Docker
```bash
# Build images
make docker-build

# Run containers (frontend on :3000, backend on :5000)
make docker-run

# Stop & remove
make docker-stop
```

Access:
- Frontend: http://localhost:3000
- Backend:  http://localhost:5000

## 💻 Development

### Project structure


```
RunStack/
├── 📁 frontend/           # React application
│   ├── 📁 src/
│   │   ├── 📁 components/ # React components
│   │   ├── 📁 api/        # API service layer
│   │   └── 📁 context/    # State management
│   ├── 📄 Dockerfile     # Frontend container
│   └── 📄 package.json   # Dependencies
├── 📁 backend/            # Flask API
│   ├── 📄 app.py         # Main application
│   ├── 📄 db.py          # Database models
│   ├── 📄 Dockerfile     # Backend container
│   └── 📄 requirements.txt
├── 📁 k8s/               # Kubernetes manifests
└── 📁 .github/workflows/ # CI/CD pipelines
```

### Development workflow

1. **Make your changes** in the appropriate directory
2. **Test locally** using the development servers
3. **Commit your changes** following conventional commits
4. **Push to your branch** - CI/CD will automatically build and test
5. **Create a Pull Request** for review

### Available scripts

**Frontend:**
```bash
npm start          # Start development server
npm run build      # Build for production
npm test           # Run test suite
```

**Backend:**
```bash
python app.py      # Start Flask development server
python test_app.py # Run backend tests
```

## 🚀 Deployment

### Live Application

Your application is live with a custom domain.

| Service | URL | Status |
|---------|-----|--------|
| 🌐 **Frontend** | [https://runstack.pp.ua/](https://runstack.pp.ua/) | ✅ Live |
| 🔌 **Backend API** | [https://runstack.pp.ua/api/products](https://runstack.pp.ua/api/products) | ✅ Live |

### Deployment options


#### 🔵 Microsoft Azure (AKS)

The application is deployed using Azure Kubernetes Service (AKS) with a custom domain configuration. The setup includes:

- **🌐 Custom Domain**: `runstack.pp.ua`
- **🔒 SSL Certificate**: Automatic HTTPS with Let's Encrypt
- **🚀 Load Balancer**: Azure Load Balancer for high availability
- **📊 Monitoring**: Azure Monitor and logging enabled

```bash
# Build & push images to ACR (branch‑aware)
./deploy.sh

# Check status
kubectl get pods,svc,ingress

# Scale
kubectl scale deployment frontend --replicas=3
```

For detailed deployment instructions, see the Kubernetes manifests in the `k8s/` directory and refer to Azure AKS documentation for cluster setup and management.

#### 🐳 Local with Minikube

```bash
# Start Minikube
minikube start

# Deploy application
chmod +x deploy.sh
./deploy.sh

# Get service URLs
minikube service frontend --url
minikube service backend --url
```

#### ☁️ Other cloud providers

Deploy the Docker images to:
- **AWS EKS** - Amazon Elastic Kubernetes Service
- **Azure AKS** - Azure Kubernetes Service (Recommended)
- **DigitalOcean** - Kubernetes or Droplets
- **Heroku** - Container deployment

## 📚 API reference

### Base URL
- **Production**: `https://runstack.pp.ua/api`
- **Local**: `http://localhost:5000/api`

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/products` | Get all products |
| `POST` | `/products` | Create a new product |
| `GET` | `/products/{id}` | Get product by ID |
| `PUT` | `/products/{id}` | Update product |
| `DELETE` | `/products/{id}` | Delete product |

### Example requests

```bash
# Get all products
curl -X GET "https://runstack.pp.ua/api/products"

# Create a product
curl -X POST "https://runstack.pp.ua/api/products" \
  -H "Content-Type: application/json" \
  -d '{"name": "New Product", "price": 29.99}'
```

## ⚙️ Configuration

### Frontend
The app supports dynamic runtime config via `public/config.js` (window.APP_CONFIG). You can also set a build‑time env var consumed by the client:

```env
# .env in frontend/
# Correct variable name used by code:
REACT_APP_API_URL=https://runstack.pp.ua/api
# Example for local dev:
# REACT_APP_API_URL=http://localhost:5000/api
```

Note: If you use Kubernetes ingress with the same host, the runtime config will default to `${window.location.origin}/api`, so you often don’t need to set this.

### Backend
```env
# Flask
FLASK_ENV=development|production
FLASK_DEBUG=false

# CORS (optional)
CORS_ORIGINS=https://runstack.pp.ua,http://localhost:3000
```

## ✅ Testing & quality

Use the Makefile helpers for a consistent workflow:

```bash
make test           # Backend + frontend tests
make test-backend   # PyTest with coverage
make test-frontend  # CRA tests with coverage
make lint           # Flake8/Black + ESLint
make format         # Auto‑format
make security       # Bandit + Safety (best‑effort)
```

## 🤝 Contributing

Contributions are welcome.
- Fork the repo and create a feature branch
- Keep PRs focused and add tests when possible
- Run make lint test before pushing

Issues and feature requests: https://github.com/roman-zvir/RunStack/issues

## 📄 License


This project is licensed under the MIT License – see the [LICENSE](LICENSE) file.

## 👨‍💻 Contact & Support

Roman Zvir – DevOps Engineer

- 🌐 Live: https://runstack.pp.ua/
- 🐙 GitHub: https://github.com/roman-zvir
- 📧 Email: zwirr151@gmail.com



---


<div align="center">
  <p>⭐ Star this repo if you found it helpful!</p>
  <p>Made with ❤️ by <a href="https://github.com/roman-zvir">Roman Zvir</a></p>
</div>

