#!/bin/bash

echo "🔍 Checking GKE deployment status..."
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl not configured. Please run:"
    echo "gcloud container clusters get-credentials YOUR_CLUSTER_NAME --zone YOUR_ZONE --project YOUR_PROJECT"
    exit 1
fi

echo "📊 Pod Status:"
kubectl get pods

echo ""
echo "🌐 Service Status:"
kubectl get services

echo ""
echo "📡 LoadBalancer External IPs:"
echo "Frontend IP: $(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo 'pending')"
echo "Backend IP: $(kubectl get service backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo 'pending')"

echo ""
echo "🔗 Access URLs (once IPs are assigned):"
FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
BACKEND_IP=$(kubectl get service backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [[ -n "$FRONTEND_IP" && "$FRONTEND_IP" != "null" ]]; then
    echo "Frontend: http://$FRONTEND_IP"
else
    echo "Frontend: Waiting for external IP..."
fi

if [[ -n "$BACKEND_IP" && "$BACKEND_IP" != "null" ]]; then
    echo "Backend: http://$BACKEND_IP"
else
    echo "Backend: Waiting for external IP..."
fi

echo ""
echo "💡 If IPs are 'pending', wait a few minutes and run this script again."
echo "💡 LoadBalancer services can take 2-5 minutes to get external IPs."
