import api from './apiClient';

export async function getProducts() {
  try {
    const response = await api.get('/products');
    const data = response.data;
    
    // Ensure we return an array
    if (Array.isArray(data)) {
      return data;
    } else if (data && typeof data === 'object') {
      // Handle case where API might wrap the array in an object
      if (data.products && Array.isArray(data.products)) {
        return data.products;
      } else if (data.data && Array.isArray(data.data)) {
        return data.data;
      } else {
        // Only log errors in development
        if (process.env.NODE_ENV === 'development') {
          // eslint-disable-next-line no-console
          console.error('API response is an object but does not contain an array:', data);
        }
        return [];
      }
    } else {
      // Only log errors in development
      if (process.env.NODE_ENV === 'development') {
        // eslint-disable-next-line no-console
        console.error('API response is not an array or object:', data);
      }
      return [];
    }
  } catch (error) {
    // Only log errors in development
    if (process.env.NODE_ENV === 'development') {
      // eslint-disable-next-line no-console
      console.error('Error fetching products:', error);
      // eslint-disable-next-line no-console
      console.error('Error details:', error.response?.data || error.message);
    }
    return [];
  }
}

export async function getProductById(id) {
  const response = await api.get(`/products/${id}`);
  return response.data;
}

export async function deleteProduct(id) {
  await api.delete(`/products/${id}`);
}

export async function addProduct(name, price) {
  const response = await api.post('/products', {
    name,
    price: parseFloat(price),
  });
  return response.data;
}

export async function patchProduct(id, name, price) {
  await api.patch(`/products/${id}`, {
    name,
    price: parseFloat(price),
  });
}
