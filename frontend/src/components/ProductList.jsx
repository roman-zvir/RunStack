import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
  getProducts as getProductsFromApi,
  deleteProduct,
} from "../api/services";

export function ProductList() {
  const [products, setProducts] = useState([]); // Initialize as empty array

  useEffect(() => {
    getProducts();
  }, []);

  const getProducts = async () => {
    try {
      const response = await getProductsFromApi();
      
      let products = response;
      
      // Handle different response formats
      if (response && typeof response === 'object') {
        // If response has a data property, use that
        if (response.data && Array.isArray(response.data)) {
          products = response.data;
        }
        // If response has a products property, use that
        else if (response.products && Array.isArray(response.products)) {
          products = response.products;
        }
        // If response itself is not an array but has array-like properties
        else if (!Array.isArray(response) && Object.keys(response).length > 0) {
          // Try to convert object values to array if they look like indexed objects
          const values = Object.values(response);
          if (values.every(item => item && typeof item === 'object' && item.id)) {
            products = values;
          } else {
            // Only log errors in development
            if (process.env.NODE_ENV === 'development') {
              // eslint-disable-next-line no-console
              console.error('Unknown response format:', response);
            }
            products = [];
          }
        }
      }
      
      // Final validation: ensure products is an array
      if (Array.isArray(products)) {
        setProducts(products);
      } else {
        // Only log errors in development
        if (process.env.NODE_ENV === 'development') {
          // eslint-disable-next-line no-console
          console.error('Could not extract array from API response:', response);
        }
        setProducts([]);
      }
    } catch (error) {
      // Only log errors in development
      if (process.env.NODE_ENV === 'development') {
        // eslint-disable-next-line no-console
        console.error('Error fetching products:', error);
      }
      setProducts([]);
    }
  };

  const deleteHandler = async (id) => {
    await deleteProduct(id);
    getProducts();
  };

  return (
    <div>
      <Link to="/add" className="button is-primary mt-2">
        Add New
      </Link>
      <table className="table is-striped is-fullwidth">
        <thead>
          <tr>
            <th>No</th>
            <th>Title</th>
            <th>Price</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {products && Array.isArray(products) && products.length > 0 ? (
            products.map((product, index) => {
              // Add safety check for product object
              if (!product || typeof product !== 'object') {
                // Only log warnings in development
                if (process.env.NODE_ENV === 'development') {
                  // eslint-disable-next-line no-console
                  console.warn('Invalid product item at index', index, ':', product);
                }
                return null;
              }
              
              return (
                <tr key={product.id || index}>
                  <td>{index + 1}</td>
                  <td>{product.name || 'N/A'}</td>
                  <td>{product.price || 'N/A'}</td>
                  <td style={{ display: "flex" }}>
                    <Link
                      style={{ marginRight: "10px" }}
                      to={`/edit/${product.id}`}
                      className="button is-small is-info"
                    >
                      Edit
                    </Link>
                    <button
                      onClick={() => deleteHandler(product.id)}
                      className="button is-small is-danger"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              );
            })
          ) : (
            <tr>
              <td colSpan="4" style={{ textAlign: 'center' }}>
                {Array.isArray(products) ? 'No products found' : 'Loading products...'}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
