<div align="center">
  <h1>🚀 React Python Playground</h1>
  <p>A modern full-stack web application built with React and Flask - Roman Zvir's Pet Project</p>

  [![Live Demo](https://img.shields.io/badge/demo-live-green.svg)](https://roman-zvir-pet-project.pp.ua/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://hub.docker.com/u/romanzvir)
  [![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/roman-zvir/react-python-playground/actions)

  [Live Demo](https://roman-zvir-pet-project.pp.ua/) • [API Docs](https://roman-zvir-pet-project.pp.ua/api/products) • [Report Bug](https://github.com/roman-zvir/react-python-playground/issues) • [Request Feature](https://github.com/roman-zvir/react-python-playground/issues)
</div>

---


<img width="1932" height="969" alt="image" src="https://github.com/user-attachments/assets/6850b394-e7e5-463d-b6cd-6aefdbdf79a4" />



## 🎯 About

React Python Playground is a production-ready full-stack web application that demonstrates modern development practices including containerization, CI/CD pipelines, and cloud deployment. Built with React frontend and Flask backend, it showcases a complete development workflow from local development to production deployment on a custom domain.

### ✨ Key Highlights

- **🔄 Full-Stack**: React frontend with Flask REST API backend
- **🐳 Containerized**: Docker-ready for any environment
- **☁️ Cloud Native**: Deployed on Google Cloud Platform with Kubernetes
- **🌐 Custom Domain**: Available at https://roman-zvir-pet-project.pp.ua/
- **🔒 SSL Secured**: HTTPS enabled with SSL certificate
- **🚀 CI/CD**: Automated builds and deployments with GitHub Actions
- **📱 Responsive**: Mobile-first design with Bulma CSS framework
- **� Production Ready**: Includes security, logging, and monitoring

## 🛠 Tech Stack

### Frontend
- **React 18** - Modern UI library with hooks
- **React Router 6** - Client-side routing
- **Axios** - HTTP client for API calls
- **Bulma** - Modern CSS framework
- **React Scripts** - Build tooling

### Backend
- **Flask 2.2** - Lightweight Python web framework
- **Flask-RESTful** - REST API extension
- **Flask-CORS** - Cross-origin resource sharing
- **Peewee ORM** - Database management
- **SQLite** - Local database

### DevOps & Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Google Cloud Platform** - Cloud hosting
- **GitHub Actions** - CI/CD pipeline
- **Docker Hub** - Container registry

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

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Python](https://www.python.org/) (v3.8 or higher)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/roman-zvir/react-python-playground.git
   cd react-python-playground
   ```

2. **Using Docker (Recommended)**
   ```bash
   # Start with Docker Compose
   docker-compose up -d
   
   # Or build and run individually
   docker build -t react-app ./frontend
   docker build -t flask-api ./backend
   ```

3. **Manual Setup**
   ```bash
   # Backend setup
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   python app.py
   
   # Frontend setup (new terminal)
   cd frontend
   npm install
   npm start
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

## 💻 Development

### Project Structure

```
react-python-playground/
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

### Development Workflow

1. **Make your changes** in the appropriate directory
2. **Test locally** using the development servers
3. **Commit your changes** following conventional commits
4. **Push to your branch** - CI/CD will automatically build and test
5. **Create a Pull Request** for review

### Available Scripts

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

Your application is **live and running** with a custom domain! 🎉

| Service | URL | Status |
|---------|-----|--------|
| 🌐 **Frontend** | [https://roman-zvir-pet-project.pp.ua/](https://roman-zvir-pet-project.pp.ua/) | ✅ Live |
| 🔌 **Backend API** | [https://roman-zvir-pet-project.pp.ua/api/products](https://roman-zvir-pet-project.pp.ua/api/products) | ✅ Live |

### Deployment Options

#### 🔵 Google Cloud Platform (Current)

The application is deployed using Google Kubernetes Engine (GKE) with a custom domain configuration. The setup includes:

- **🌐 Custom Domain**: `roman-zvir-pet-project.pp.ua`
- **🔒 SSL Certificate**: Automatic HTTPS with Let's Encrypt
- **🚀 Load Balancer**: Google Cloud Load Balancer for high availability
- **📊 Monitoring**: Cloud monitoring and logging enabled

```bash
# Check deployment status
kubectl get pods
kubectl get services
kubectl get ingress

# Scale your application
kubectl scale deployment frontend --replicas=3

# Update deployment
./deploy.sh
```

For detailed deployment instructions, see the Kubernetes manifests in the `k8s/` directory.

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

#### ☁️ Other Cloud Providers

Deploy the Docker images to:
- **AWS EKS** - Amazon Elastic Kubernetes Service
- **Azure AKS** - Azure Kubernetes Service
- **DigitalOcean** - Kubernetes or Droplets
- **Heroku** - Container deployment

## 📚 API Reference

### Base URL
- **Production**: `https://roman-zvir-pet-project.pp.ua/api`
- **Local**: `http://localhost:5000/api`

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/products` | Get all products |
| `POST` | `/products` | Create a new product |
| `GET` | `/products/{id}` | Get product by ID |
| `PUT` | `/products/{id}` | Update product |
| `DELETE` | `/products/{id}` | Delete product |

### Example Requests

```bash
# Get all products
curl -X GET "https://roman-zvir-pet-project.pp.ua/api/products"

# Create a product
curl -X POST "https://roman-zvir-pet-project.pp.ua/api/products" \
  -H "Content-Type: application/json" \
  -d '{"name": "New Product", "price": 29.99}'
```

## ⚙️ Environment Variables

### Frontend Configuration

Create a `.env` file in the `frontend` directory:

```env
# API Base URL - Production
REACT_APP_BASE_URL=https://roman-zvir-pet-project.pp.ua/api

# API Base URL - Local development
# REACT_APP_BASE_URL=http://localhost:5000/api

# Optional: Enable development features
REACT_APP_DEBUG=false
```

### Backend Configuration

The backend uses environment variables for configuration:

```env
# Database
DATABASE_URL=sqlite:///products.db

# Flask settings
FLASK_ENV=production
FLASK_DEBUG=false

# CORS settings
CORS_ORIGINS=https://roman-zvir-pet-project.pp.ua,http://localhost:3000
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Setup

```bash
# Fork and clone your fork
git clone https://github.com/YOUR_USERNAME/react-python-playground.git
cd react-python-playground

# Add upstream remote
git remote add upstream https://github.com/roman-zvir/react-python-playground.git

# Create a new branch
git checkout -b feature/your-feature-name
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Contact & Support

**Roman Zvir** - DevOps Engineer

- 🌐 **Live Project**: [https://roman-zvir-pet-project.pp.ua/](https://roman-zvir-pet-project.pp.ua/)
- 🐙 **GitHub**: [@roman-zvir](https://github.com/roman-zvir)
- 📧 **Email**: [zwirr151@gmail.com](mailto:zwirr151@gmail.com)
- 💼 **LinkedIn**: Connect with me for professional inquiries



---

<div align="center">
  <p>⭐ Star this repo if you found it helpful!</p>
  <p>Made with ❤️ by <a href="https://github.com/roman-zvir">Roman Zvir</a></p>
</div>

