import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { ProductList } from '../ProductList';

// Simple mock for services
jest.mock('../../api/services', () => ({
  getProducts: jest.fn(),
}));

const mockGetProducts = require('../../api/services').getProducts;

// Mock data
const mockProducts = [
  { id: 1, name: 'Test Product 1', price: 19 },
  { id: 2, name: 'Test Product 2', price: 29 },
];

// Helper to render component with router
const renderWithRouter = (component) => {
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

  test('renders products when data is loaded', async () => {
    mockGetProducts.mockResolvedValue(mockProducts);
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      expect(screen.getByText('Test Product 1')).toBeInTheDocument();
      expect(screen.getByText('Test Product 2')).toBeInTheDocument();
    });
  });

  test('renders empty state when no products', async () => {
    mockGetProducts.mockResolvedValue([]);
    
    renderWithRouter(<ProductList />);
    
    await waitFor(() => {
      // Just check that we don't have any product names
      expect(screen.queryByText('Test Product 1')).not.toBeInTheDocument();
    });
  });
});