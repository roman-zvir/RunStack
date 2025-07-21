import pytest
import json
from app import app
from db import ProductModel, db


@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    app.config['DATABASE'] = ':memory:'  # Use in-memory database for tests
    
    with app.test_client() as client:
        with app.app_context():
            # Create tables
            db.create_tables([ProductModel], safe=True)
        yield client


@pytest.fixture
def sample_product():
    """Create a sample product for testing."""
    return {
        'name': 'Test Product',
        'price': 29.99
    }


class TestProductsAPI:
    """Test cases for Products API endpoints."""
    
    def test_get_empty_products(self, client):
        """Test getting products when database is empty."""
        response = client.get('/api/products')
        assert response.status_code == 200
        assert json.loads(response.data) == []
    
    def test_create_product(self, client, sample_product):
        """Test creating a new product."""
        response = client.post('/api/products', 
                             data=json.dumps(sample_product),
                             content_type='application/json')
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data['name'] == sample_product['name']
        assert data['price'] == sample_product['price']
        assert 'id' in data
    
    def test_create_product_missing_name(self, client):
        """Test creating product without name should fail."""
        response = client.post('/api/products', 
                             data=json.dumps({'price': 29.99}),
                             content_type='application/json')
        assert response.status_code == 400
    
    def test_create_product_missing_price(self, client):
        """Test creating product without price should fail."""
        response = client.post('/api/products', 
                             data=json.dumps({'name': 'Test Product'}),
                             content_type='application/json')
        assert response.status_code == 400
    
    def test_get_products_after_creation(self, client, sample_product):
        """Test getting products after creating one."""
        # Create a product first
        client.post('/api/products', 
                   data=json.dumps(sample_product),
                   content_type='application/json')
        
        # Get all products
        response = client.get('/api/products')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert len(data) == 1
        assert data[0]['name'] == sample_product['name']


class TestProductAPI:
    """Test cases for individual Product API endpoints."""
    
    def test_get_nonexistent_product(self, client):
        """Test getting a product that doesn't exist."""
        response = client.get('/api/products/999')
        assert response.status_code == 404
    
    def test_update_nonexistent_product(self, client):
        """Test updating a product that doesn't exist."""
        response = client.put('/api/products/999',
                            data=json.dumps({'name': 'Updated', 'price': 19.99}),
                            content_type='application/json')
        assert response.status_code == 404
    
    def test_delete_nonexistent_product(self, client):
        """Test deleting a product that doesn't exist."""
        response = client.delete('/api/products/999')
        assert response.status_code == 404


class TestHealthCheck:
    """Test cases for health check endpoints."""
    
    def test_health_endpoint(self, client):
        """Test the health check endpoint."""
        response = client.get('/health')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['status'] == 'healthy'
        assert 'timestamp' in data
        assert 'version' in data