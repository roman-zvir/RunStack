import api from './apiClient';

export async function getProducts() {
  try {
    console.log('Making API request to /products...');
    const response = await api.get('/products');
    console.log('Raw API response:', response);
    console.log('Response data:', response.data);
    console.log('Response data type:', typeof response.data);
    console.log('Response data is array:', Array.isArray(response.data));
    
    const data = response.data;
    
    // Ensure we return an array
    if (Array.isArray(data)) {
      console.log('Returning array with', data.length, 'items');
      return data;
    } else if (data && typeof data === 'object') {
      // Handle case where API might wrap the array in an object
      if (data.products && Array.isArray(data.products)) {
        console.log('Found products array in response object');
        return data.products;
      } else if (data.data && Array.isArray(data.data)) {
        console.log('Found data array in response object');
        return data.data;
      } else {
        console.error('API response is an object but does not contain an array:', data);
        return [];
      }
    } else {
      console.error('API response is not an array or object:', data);
      return [];
    }
  } catch (error) {
    console.error('Error fetching products:', error);
    console.error('Error details:', error.response?.data || error.message);
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
