import axios from 'axios';

// Create axios instance with runtime URL detection
const getBaseURL = () => {
  // Use dynamic runtime configuration for container (Minikube) deployments
  if (typeof window !== 'undefined' && window.APP_CONFIG) {
    return window.APP_CONFIG.getApiUrl();
  }
  // Allow override via environment variable
  if (process.env.REACT_APP_API_URL) {
    // eslint-disable-next-line no-console
    console.log('Using API URL from env:', process.env.REACT_APP_API_URL);
    return process.env.REACT_APP_API_URL;
  }
  
  // Fallback: runtime detection without config
  if (typeof window !== 'undefined') {
    const currentHost = window.location.hostname;
    const currentPort = window.location.port;
    
    // Check if we're in Minikube environment (accessing via Minikube IP)
    if (currentHost.match(/^192\.168\.\d+\.\d+$/)) {
      return `http://${currentHost}:31977/api`;
    }
    
    // Check if we're accessing localhost but likely in Minikube context
    // If port is 30593 (frontend NodePort), use Minikube backend
    if ((currentHost === 'localhost' || currentHost === '127.0.0.1') && currentPort === '30593') {
      return 'http://192.168.39.117:31977/api';
    }
    
    // Standard localhost development
    if (currentHost === 'localhost' || currentHost === '127.0.0.1') {
      return 'http://localhost:5000/api';
    }
    
    // GKE deployment - check if we're accessing via external IP
    if (currentHost.match(/^\d+\.\d+\.\d+\.\d+$/)) {
      return 'http://34.10.145.23/api';
    }
    
    return `http://${currentHost}:31977/api`;
  }
  
  // Server-side fallback
  return 'http://backend:5000/api';
};

const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
});

// Log the actual base URL being used
// eslint-disable-next-line no-console
console.log('API Client initialized with baseURL:', getBaseURL());

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Ensure we don't have any problematic headers
    if (config.headers) {
      delete config.headers['X-Requested-With'];
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response) {
      // Server responded with error status
    } else if (error.request) {
      // Request was made but no response received
    } else {
      // Something else happened
    }
    return Promise.reject(error);
  }
);

export default api;
