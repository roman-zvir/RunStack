import api from './apiClient';

export async function getProducts() {
  const response = await api.get('/products');
  return response.data;
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
