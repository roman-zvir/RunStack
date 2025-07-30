import React, { useState, useEffect, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  patchProduct,
  getProductById as getProductFromApi,
} from "../api/services";

export function EditProduct() {
  const [title, setTitle] = useState("");
  const [price, setPrice] = useState("");
  const [errors, setErrors] = useState({});
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();
  const { id } = useParams();
  const validate = () => {
    const newErrors = {};
    if (!title.trim()) {
      newErrors.title = "Title is required.";
    } else if (title.trim().length < 3) {
      newErrors.title = "Title must be at least 3 characters.";
    }
    if (!price.toString().trim()) {
      newErrors.price = "Price is required.";
    } else if (isNaN(Number(price)) || Number(price) <= 0) {
      newErrors.price = "Price must be a positive number.";
    }
    return newErrors;
  };

  const updateProduct = async (e) => {
    e.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) {
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
      setErrors({ submit: errorMessage });
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
      <form onSubmit={updateProduct} noValidate>
        <div className="field">
          <label className="label">Title</label>
          <input
            className={`input${errors.title ? " is-danger" : ""}`}
            type="text"
            placeholder="Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          {errors.title && (
            <p className="help is-danger">{errors.title}</p>
          )}
        </div>

        <div className="field">
          <label className="label">Price</label>
          <input
            className={`input${errors.price ? " is-danger" : ""}`}
            type="text"
            placeholder="Price"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
          />
          {errors.price && (
            <p className="help is-danger">{errors.price}</p>
          )}
        </div>

        {errors.submit && (
          <div className="notification is-danger is-light">{errors.submit}</div>
        )}

        <div className="field">
          <button className="button is-primary">Update</button>
        </div>
      </form>
    </div>
  );
}
