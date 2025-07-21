// Runtime configuration that gets loaded dynamically
window.APP_CONFIG = {
  // This will be dynamically set based on the current hostname
  getApiUrl: function() {
    const currentHost = window.location.hostname;
    const currentPort = window.location.port;
    
    console.log('Dynamic config - Current host:', currentHost, 'Port:', currentPort);
    
    // Check if we're accessing via Minikube IP directly
    if (currentHost.match(/^192\.168\.\d+\.\d+$/)) {
      const apiUrl = `http://${currentHost}:31977/api`;
      console.log('Using Minikube IP backend URL:', apiUrl);
      return apiUrl;
    }
    
    // If running on localhost but with Minikube frontend port, use Minikube backend
    if ((currentHost === 'localhost' || currentHost === '127.0.0.1') && currentPort === '30593') {
      const apiUrl = 'http://192.168.39.117:31977/api';
      console.log('Using Minikube backend from localhost frontend:', apiUrl);
      return apiUrl;
    }
    
    // If running on localhost (pure development), use localhost backend
    if (currentHost === 'localhost' || currentHost === '127.0.0.1') {
      console.log('Using localhost backend');
      return 'http://localhost:5000/api';
    }
    
    // GKE deployment - frontend runs on 34.172.36.134, backend on 104.155.134.17
    if (currentHost === '34.172.36.134') {
      const apiUrl = 'http://104.155.134.17/api';
      console.log('Using GKE backend URL:', apiUrl);
      return apiUrl;
    }
    
    // Fallback for GKE: if we're accessing via external IP, use the backend LoadBalancer IP
    if (currentHost.match(/^\d+\.\d+\.\d+\.\d+$/)) {
      const apiUrl = 'http://104.155.134.17/api';
      console.log('Using GKE backend URL for external IP access:', apiUrl);
      return apiUrl;
    }
    
    // For any other host, use port 31977 (Minikube/local development)
    const apiUrl = `http://${currentHost}:31977/api`;
    console.log('Using dynamic backend URL:', apiUrl);
    return apiUrl;
  }
};
