import React, { useState, useEffect, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  patchProduct,
  getProductById as getProductFromApi,
} from "../api/services";

export function EditProduct() {
  const [title, setTitle] = useState("");
  const [price, setPrice] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();
  const { id } = useParams();
  const updateProduct = async (e) => {
    e.preventDefault();
    // Validate inputs
    if (!title.trim()) {
      alert('Please enter a product title');
      return;
    }
    if (!price.trim() || isNaN(parseFloat(price))) {
      alert('Please enter a valid price');
      return;
    }
    try {
      await patchProduct(id, title, price);
      navigate("/");
    } catch (error) {
      let errorMessage = 'Failed to update product. ';
      if (error.response?.data?.message) {
        errorMessage += error.response.data.message;
      } else if (error.message) {
        errorMessage += error.message;
      } else {
        errorMessage += 'Please check the console for details.';
      }
      alert(errorMessage);
    }
  };

  const getProductById = useCallback(async () => {
    const response = await getProductFromApi(id);
    setTitle(response.name);
    setPrice(response.price);
    setIsLoading(false);
  }, [id]);

  useEffect(() => {
    getProductById();
  }, [getProductById]);
  if (isLoading) return <p>Loading...</p>;
  return (
    <div>
      <form onSubmit={updateProduct}>
        <div className="field">
          <label className="label">Title</label>
          <input
            className="input"
            type="text"
            placeholder="Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
        </div>

        <div className="field">
          <label className="label">Price</label>
          <input
            className="input"
            type="text"
            placeholder="Price"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
          />
        </div>

        <div className="field">
          <button className="button is-primary">Update</button>
        </div>
      </form>
    </div>
  );
}
