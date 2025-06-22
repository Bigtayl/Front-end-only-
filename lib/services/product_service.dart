// product_service.dart
// Simple product service for frontend-only version
// Provides mock data directly

import '../models/product.dart';
import 'mock_data_service.dart';

class ProductService {
  final MockDataService _mockDataService = MockDataService();

  /// Get all products
  List<Product> getAllProducts() {
    return _mockDataService.getSampleProducts();
  }

  /// Get products by category
  List<Product> getProductsByCategory(String category) {
    final allProducts = _mockDataService.getSampleProducts();
    return allProducts
        .where((product) => product.category == category)
        .toList();
  }

  /// Search products by name
  List<Product> searchProducts(String query) {
    final allProducts = _mockDataService.getSampleProducts();
    return allProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get products by price range
  List<Product> getProductsByPriceRange(double minPrice, double maxPrice) {
    final allProducts = _mockDataService.getSampleProducts();
    return allProducts
        .where(
            (product) => product.price >= minPrice && product.price <= maxPrice)
        .toList();
  }
}
