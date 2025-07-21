import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { ProductList } from '../ProductList';
import * as services from '../../api/services';

// Mock the services module
jest.mock('../../api/services');
const mockServices = services as jest.Mocked<typeof services>;

// Mock data
const mockProducts = [
  { id: 1, name: 'Test Product 1', price: 19.99 },
  { id: 2, name: 'Test Product 2', price: 29.99 },
];

// Helper to render component with router
const renderWithRouter = (component: React.ReactElement) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  );
};

describe('ProductList Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders loading state initially', () => {
    mockServices.getProducts.mockImplementation(() => new Promise(() => {})); // Never resolves
    
    renderWithRouter(<ProductList />);
    
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  test('renders products when data is loaded', async () => {
    mockServices.getProducts.mockResolvedValue(mockProducts);
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      expect(screen.getByText('Test Product 1')).toBeInTheDocument();
      expect(screen.getByText('Test Product 2')).toBeInTheDocument();
      expect(screen.getByText('$19.99')).toBeInTheDocument();
      expect(screen.getByText('$29.99')).toBeInTheDocument();
    });
  });

  test('renders empty state when no products', async () => {
    mockServices.getProducts.mockResolvedValue([]);
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      expect(screen.getByText(/no products found/i)).toBeInTheDocument();
    });
  });

  test('renders error state when API fails', async () => {
    mockServices.getProducts.mockRejectedValue(new Error('API Error'));
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      expect(screen.getByText(/error loading products/i)).toBeInTheDocument();
    });
  });

  test('has edit and delete buttons for each product', async () => {
    mockServices.getProducts.mockResolvedValue(mockProducts);
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      const editButtons = screen.getAllByText(/edit/i);
      const deleteButtons = screen.getAllByText(/delete/i);
      
      expect(editButtons).toHaveLength(mockProducts.length);
      expect(deleteButtons).toHaveLength(mockProducts.length);
    });
  });
});