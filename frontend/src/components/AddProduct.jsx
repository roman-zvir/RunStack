import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { addProduct } from "../api/services";

export function AddProduct() {
  const [title, setTitle] = useState("");
  const [price, setPrice] = useState("");
  const navigate = useNavigate();
  const saveProduct = async (e) => {
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
      await addProduct(title, price);
      
      // Clear form
      setTitle("");
      setPrice("");
      
      // Navigate back to product list
      navigate("/");
    } catch (error) {
      let errorMessage = 'Failed to add product. ';
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

  return (
    <div>
      <form onSubmit={saveProduct}>
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
        <button className="button is-primary">Save</button>
      </form>
    </div>
  );
}
