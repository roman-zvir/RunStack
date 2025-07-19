import axios from 'axios';

// Create axios instance with better configuration
// Fallback to external Minikube URL if the environment variable points to internal service
const getBaseURL = () => {
  const envURL = process.env.REACT_APP_BASE_URL;
  // If running in browser and URL points to internal service, use external URL
  if (typeof window !== 'undefined' && envURL && envURL.includes('backend:5000')) {
    return 'http://192.168.39.117:31977/api';
  }
  return envURL || 'http://192.168.39.117:31977/api';
};

const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
});

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
