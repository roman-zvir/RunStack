// Runtime configuration that gets loaded dynamically
window.APP_CONFIG = {
// This will be dynamically set based on the current hostname
getApiUrl: function() {
const currentHost = window.location.hostname;
const currentPort = window.location.port;
console.log('Dynamic config - Current host:', currentHost, 'Port:', currentPort);

// Check if we're accessing via Minikube IP directly
if (currentHost.match(/^192\.168\.\d+\.\d+$/)) {
const apiUrl = `https://${currentHost}:31977/api`;
console.log('Using Minikube IP backend URL:', apiUrl);
return apiUrl;
}

// If running on localhost but with Minikube frontend port, use Minikube backend
if ((currentHost === 'localhost' || currentHost === '127.0.0.1') && currentPort === '30593') {
const apiUrl = 'https://192.168.39.117:31977/api';
console.log('Using Minikube backend from localhost frontend:', apiUrl);
return apiUrl;
}

// If running on localhost (pure development), use localhost backend
if (currentHost === 'localhost' || currentHost === '127.0.0.1') {
console.log('Using localhost backend');
return 'https://localhost:5000/api';
}

// GKE deployment - frontend runs on 34.29.235.29, backend on 34.16.74.187 (LoadBalancer IPs)
if (currentHost === '34.29.235.29') {
const apiUrl = 'https://34.16.74.187/api';
console.log('Using GKE backend URL:', apiUrl);
return apiUrl;
}

// Fallback for GKE: if we're accessing via external IP, use the backend LoadBalancer IP
if (currentHost.match(/^\d+\.\d+\.\d+\.\d+$/) && currentHost !== '34.29.235.29') {
const apiUrl = 'https://34.16.74.187/api';
console.log('Using GKE backend URL for external IP access:', apiUrl);
return apiUrl;
}

// For domain-based deployment (like roman-zvir-pet-project.pp.ua)
const protocol = window.location.protocol; // Use current protocol instead of forcing 'https:'
console.log('Checking domain-based deployment - protocol:', protocol, 'host:', currentHost);

// Check if it's a domain-based deployment (e.g., .pp.ua, .com)
if (currentHost.includes('.') && !currentHost.match(/^\d+\.\d+\.\d+\.\d+$/)) {
// Use same domain with /api path (matches ingress configuration) 
const apiUrl = `${protocol}//${currentHost}/api`;
console.log('Using domain-based ingress backend URL:', apiUrl);
return apiUrl;
}

// FIXED: Default fallback should also use HTTPS for domain deployments
const apiUrl = `https://${currentHost}:31977/api`;
console.log('Using default fallback backend URL:', apiUrl);
return apiUrl;
}
};