# Domain Setup Guide

## Overview
This guide will help you set up a custom domain for your React-Python application deployed on Google Kubernetes Engine (GKE).

## Prerequisites
1. A registered domain name
2. Access to your domain's DNS settings
3. GKE cluster with Ingress controller enabled

## Steps to Set Up Your Domain

### 1. Reserve a Static IP Address
First, reserve a static IP address in Google Cloud:

```bash
# Reserve a global static IP
gcloud compute addresses create app-static-ip --global

# Get the reserved IP address
gcloud compute addresses describe app-static-ip --global
```

### 2. Update DNS Records
In your domain registrar's DNS settings, create the following records:
- **A Record**: `your-domain.com` → `[STATIC_IP_ADDRESS]`
- **A Record**: `www.your-domain.com` → `[STATIC_IP_ADDRESS]`

### 3. Update Kubernetes Configuration

#### Replace placeholders in the files:
1. In `k8s/ingress.yaml`:
   - Replace `your-domain.com` with your actual domain
   - Update the static IP name if different from `app-static-ip`

2. In `k8s/frontend-deployment.yaml`:
   - Replace `your-domain.com` with your actual domain

### 4. Set Up SSL Certificate (Recommended)

#### Option A: Google-managed SSL Certificate
```bash
# Create a managed certificate
kubectl apply -f - <<EOF
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: app-ssl-cert
spec:
  domains:
    - your-domain.com
    - www.your-domain.com
EOF
```

Then update your `ingress.yaml` to include:
```yaml
metadata:
  annotations:
    networking.gke.io/managed-certificates: app-ssl-cert
```

#### Option B: Let's Encrypt with cert-manager
```bash
# Install cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: gce
EOF
```

### 5. Deploy the Configuration
```bash
# Apply all Kubernetes configurations
kubectl apply -f k8s/

# Check ingress status
kubectl get ingress app-ingress

# Check certificate status (if using managed certificates)
kubectl describe managedcertificate app-ssl-cert
```

### 6. Verification
1. Wait for DNS propagation (can take up to 48 hours)
2. Check that your domain resolves to the correct IP:
   ```bash
   nslookup your-domain.com
   ```
3. Test your application:
   - Frontend: `https://your-domain.com`
   - Backend API: `https://your-domain.com/api`

## Troubleshooting

### Common Issues:
1. **502/503 Errors**: Check if your services and pods are running correctly
2. **SSL Certificate Issues**: Ensure domain ownership verification is complete
3. **DNS Issues**: Verify DNS records are correctly configured

### Useful Commands:
```bash
# Check ingress details
kubectl describe ingress app-ingress

# Check service endpoints
kubectl get endpoints

# Check pod logs
kubectl logs -l app=frontend
kubectl logs -l app=backend

# Check certificate status
kubectl get managedcertificate
```

## Security Considerations
1. Always use HTTPS in production
2. Consider adding security headers in your ingress
3. Implement proper CORS policies in your backend
4. Use network policies to restrict pod-to-pod communication

## Cost Optimization
- Use a single static IP for the ingress instead of multiple LoadBalancer IPs
- Consider using regional persistent disks if you have databases
- Monitor your GKE cluster resource usage
