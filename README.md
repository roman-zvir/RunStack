# React + Flask Application

This repository contains a full-stack web application with a **React** frontend and a **Flask** backend, containerized using Docker. A **CI/CD pipeline** with GitHub Actions automates building and pushing Docker images to Docker Hub.

## Features

- **React Frontend**: Served on port `3000`
- **Flask Backend**: API served on port `5000`
- **Dockerized**: Containerized for efficient deployment
- **CI/CD Pipeline**: Automates builds and pushes to Docker Hub
- **Docker Hub Integration**: Images published automatically

## Getting Started

### Prerequisites

- Docker and Minikube (with kubectl)
- Node.js and npm (for local frontend development)
- Python 3.8+ and pip (for local backend development)
- GitHub account with repository access
- Docker Hub account

### Clone the Repository

```bash
git clone https://github.com/roman-zvir/react-python-playground.git
cd react-python-playground
```

## Local Development

### Run the Frontend

Install dependencies and start the frontend development server:

```bash
cd frontend
npm install
npm start
```

Access the frontend at `http://localhost:3000`.

### Run the Backend

Install dependencies and start the Flask server:

```bash
cd backend
pip install -r requirements.txt
flask run
```

Access the backend API at `http://localhost:5000`.

## Local Deployment with Minikube

Ensure Minikube is installed and running, then use the provided script to build and deploy the application:

```bash
minikube start
chmod +x deploy.sh
./deploy.sh
```

Once deployed, retrieve the service URLs:

```bash
minikube service frontend --url
minikube service backend --url
```

## CI/CD Pipeline

On every push to the `main` branch, GitHub Actions:

- Builds Docker images for frontend and backend
- Runs tests (if configured)
- Pushes images to Docker Hub under your account

## Deployment

### Google Cloud Platform (GCP) - Recommended

Your application is already deployed and running on GCP! 🚀

**Live URLs:**
- Frontend: http://34.66.141.78:3000
- Backend API: http://104.155.134.17:5000/api/products

For detailed GCP deployment instructions, see [GCP_DEPLOYMENT.md](./GCP_DEPLOYMENT.md).

**Quick GCP Commands:**
```bash
# Check deployment status
kubectl get pods
kubectl get services

# Scale your application
kubectl scale deployment frontend --replicas=3

# Update with new images
./deploy.sh
```

### Other Options

Deploy the Docker images to other container orchestration platforms like Kubernetes or cloud virtual machines.

## Environment Variables

Configure frontend environment variables in a `.env` file. 
you will find it in:
```
minikube service backend --url
```
Example:

```env
REACT_APP_BASE_URL=http://192.168.39.117:31977/api
```

## License

Licensed under the MIT License.

## Contact

Created by [Roman Zvir](https://github.com/roman-zvir)

