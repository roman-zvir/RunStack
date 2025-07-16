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

- **Docker** and **Docker Compose**
- **Node.js** and **npm** (for local frontend development)
- **Python 3.8+** and **pip** (for local backend development)
- **GitHub** account with repository access
- **Docker Hub** account

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

## Using Docker

### Build Docker Images

Build images for the frontend and backend:

```bash
docker build -t backend ./backend
docker build -t frontend ./frontend
```

### Run Docker Containers

Run the containers to serve the application:

```bash
docker run -p 5000:5000 backend
docker run -p 3000:3000 frontend
```

Access the backend at `http://localhost:5000` and the frontend at `http://localhost:3000`.

## CI/CD Pipeline

On every push to the `main` branch, GitHub Actions:

- Builds Docker images for frontend and backend
- Runs tests (if configured)
- Pushes images to Docker Hub under your account

## Deployment

Deploy the Docker images to a container orchestration platform like Kubernetes or a cloud virtual machine.

## Environment Variables

Configure frontend environment variables in a `.env` file. Example:

```env
REACT_APP_API_URL=http://localhost:5000/api
```

## License

Licensed under the MIT License.

## Contact

Created by [Roman Zvir](https://github.com/roman-zvir)

