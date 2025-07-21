import pytest
import json
import tempfile
import os
from app import app
from db import ProductModel, db


@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    # Create a temporary database file
    db_fd, db_path = tempfile.mkstemp()
    app.config["TESTING"] = True

    # Update the database path for testing
    db.init(db_path)

    with app.test_client() as client:
        with app.app_context():
            # Create tables fresh for each test
            db.drop_tables([ProductModel], safe=True)
            db.create_tables([ProductModel], safe=True)
        yield client

    # Clean up
    os.close(db_fd)
    os.unlink(db_path)


@pytest.fixture
def sample_product():
    """Create a sample product for testing."""
    return {
        "name": "Test Product",
        "price": 30,  # Use integer price to match database behavior
    }


class TestProductsAPI:
    """Test cases for Products API endpoints."""

    def test_get_empty_products(self, client):
        """Test getting products when database is empty."""
        response = client.get("/api/products")
        assert response.status_code == 200
        assert json.loads(response.data) == []

    def test_create_product(self, client, sample_product):
        """Test creating a new product."""
        response = client.post(
            "/api/products",
            data=json.dumps(sample_product),
            content_type="application/json",
        )
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data["message"] == "Product added successfully."
        assert "productId" in data

    def test_create_product_missing_price(self, client):
        """Test creating product without price should fail."""
        response = client.post(
            "/api/products",
            data=json.dumps({"name": "Test Product"}),
            content_type="application/json",
        )
        assert response.status_code == 400

    def test_create_product_missing_name(self, client):
        """Test creating product without name should fail."""
        response = client.post(
            "/api/products",
            data=json.dumps({"price": 30}),
            content_type="application/json",
        )
        assert response.status_code == 400

    def test_get_products_after_creation(self, client, sample_product):
        """Test getting products after creating one."""
        # Create a product first
        client.post(
            "/api/products",
            data=json.dumps(sample_product),
            content_type="application/json",
        )

        # Get all products
        response = client.get("/api/products")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert len(data) == 1
        assert data[0]["name"] == sample_product["name"]
        # Exact match since we're using integer prices
        assert data[0]["price"] == sample_product["price"]


class TestProductAPI:
    """Test cases for individual Product API endpoints."""

    def test_get_nonexistent_product(self, client):
        """Test getting a product that doesn't exist."""
        response = client.get("/api/products/999")
        assert response.status_code == 404
        data = json.loads(response.data)
        assert "error" in data

    def test_get_existing_product(self, client, sample_product):
        """Test getting an existing product."""
        # Create a product first
        create_response = client.post(
            "/api/products",
            data=json.dumps(sample_product),
            content_type="application/json",
        )
        product_id = json.loads(create_response.data)["productId"]

        # Get the product
        response = client.get(f"/api/products/{product_id}")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["name"] == sample_product["name"]
        # Exact match since we're using integer prices
        assert data["price"] == sample_product["price"]

    def test_update_nonexistent_product(self, client):
        """Test updating a product that doesn't exist."""
        response = client.patch(
            "/api/products/999",
            data=json.dumps({"name": "Updated", "price": 19.99}),
            content_type="application/json",
        )
        assert response.status_code == 404

    def test_update_existing_product(self, client, sample_product):
        """Test updating an existing product."""
        # Create a product first
        create_response = client.post(
            "/api/products",
            data=json.dumps(sample_product),
            content_type="application/json",
        )
        product_id = json.loads(create_response.data)["productId"]

        # Update the product
        update_data = {"name": "Updated Product", "price": 40}
        response = client.patch(
            f"/api/products/{product_id}",
            data=json.dumps(update_data),
            content_type="application/json",
        )
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["message"] == "Product updated successfully."

        # Verify the update
        get_response = client.get(f"/api/products/{product_id}")
        updated_product = json.loads(get_response.data)
        assert updated_product["name"] == update_data["name"]
        # Exact match since we're using integer prices
        assert updated_product["price"] == update_data["price"]

    def test_delete_nonexistent_product(self, client):
        """Test deleting a product that doesn't exist."""
        response = client.delete("/api/products/999")
        assert response.status_code == 404

    def test_delete_existing_product(self, client, sample_product):
        """Test deleting an existing product."""
        # Create a product first
        create_response = client.post(
            "/api/products",
            data=json.dumps(sample_product),
            content_type="application/json",
        )
        product_id = json.loads(create_response.data)["productId"]

        # Delete the product
        response = client.delete(f"/api/products/{product_id}")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["message"] == "Product deleted."

        # Verify it's deleted
        get_response = client.get(f"/api/products/{product_id}")
        assert get_response.status_code == 404


class TestHealthCheck:
    """Test cases for health check endpoints."""

    def test_health_endpoint(self, client):
        """Test the health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert "version" in data
