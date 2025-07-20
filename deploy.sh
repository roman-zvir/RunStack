#!/usr/bin/env bash
eval $(minikube docker-env)
# backend
docker build -t backend:latest ./backend
docker tag backend:latest gcr.io/intern-466414/backend:latest
docker push gcr.io/intern-466414/backend:latest
# frontend
docker build -t frontend:latest ./frontend
docker tag frontend:latest gcr.io/intern-466414/frontend:latest
docker push gcr.io/intern-466414/frontend:latest
# deploy
kubectl set image deployment/backend backend=gcr.io/intern-466414/backend:latest
kubectl set image deployment/frontend frontend=gcr.io/intern-466414/frontend:latest
kubectl rollout status deployment/backend
kubectl rollout status deployment/frontend