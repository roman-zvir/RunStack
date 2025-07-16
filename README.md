
---

````markdown
# React + Flask Application with CI/CD and Docker

This repository contains a full-stack web application with a **React** frontend and a **Flask** backend. The app is containerized with Docker, and a **CI/CD pipeline** is configured to build and push Docker images to Docker Hub automatically.

---

## Features

- React frontend served on port 3000
- Flask backend API served on port 5000
- Dockerized for easy deployment
- CI/CD pipeline using GitHub Actions
- Docker images pushed automatically to Docker Hub

---

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Node.js and npm (for local frontend development)
- Python 3.8+ and pip (for local backend development)
- GitHub account with repo access
- Docker Hub account

### Clone the repository

```bash
git clone https://github.com/roman-zvir/react-python-playground.git
cd react-python-playground
````

---

## Local Development

### Run Frontend

```bash
cd frontend
npm install
npm start
```

Frontend will be available at: `http://localhost:3000`

### Run Backend

```bash
cd backend
pip install -r requirements.txt
flask run
```

Backend API will be available at: `http://localhost:5000`

---

## Using Docker

### Build Docker Images Locally

```bash
docker build -t backend ./backend
docker build -t frontend ./frontend
```

### Run Docker Containers Locally

```bash
docker run -p 5000:5000 backend
docker run -p 3000:3000 frontend
```

---

## CI/CD Pipeline

* On every push to `main`, GitHub Actions will:

  * Build Docker images for frontend and backend
  * Run tests (if configured)
  * Push images to Docker Hub under your account

---

## Deployment

You can deploy the Docker images to any container orchestration platform like Kubernetes or directly on a cloud VM.

---

## Environment Variables

* Frontend `.env` example:

```
REACT_APP_API_URL=http://localhost:5000/api
```
---

## License

This project is licensed under the MIT License.

---

## Contact

Created by [Roman Zvir](https://github.com/roman-zvir)

```
