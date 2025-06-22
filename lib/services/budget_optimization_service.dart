// budget_optimization_service.dart
// Simple budget optimization service for frontend-only app

import '../models/product.dart';

/// Simple budget optimization service
class BudgetOptimizationService {
  /// Get products within budget
  List<Product> getProductsWithinBudget({
    required List<Product> products,
    required double budget,
  }) {
    if (products.isEmpty || budget <= 0) {
      return [];
    }

    // Simply filter products within budget
    return products.where((product) => product.price <= budget).toList();
  }

  /// Calculate budget usage percentage
  double calculateBudgetUsage({
    required List<Product> selectedProducts,
    required double budget,
  }) {
    if (budget <= 0) return 0.0;

    final totalCost = selectedProducts.fold<double>(
        0.0, (sum, product) => sum + product.price);

    return (totalCost / budget) * 100;
  }

  /// Get budget suggestions
  List<String> getBudgetSuggestions({
    required double budget,
    required List<Product> selectedProducts,
  }) {
    final suggestions = <String>[];
    final totalCost = selectedProducts.fold<double>(
        0.0, (sum, product) => sum + product.price);

    if (totalCost > budget) {
      suggestions
          .add('Bütçenizi aştınız! Daha uygun fiyatlı alternatifler önerilir.');
    } else if (totalCost < budget * 0.5) {
      suggestions.add(
          'Bütçenizin yarısından azını kullandınız. Daha fazla besin çeşitliliği ekleyebilirsiniz.');
    } else if (totalCost < budget * 0.8) {
      suggestions.add('Bütçenizi verimli kullanıyorsunuz!');
    } else {
      suggestions.add('Bütçenizi maksimum verimle kullandınız!');
    }

    return suggestions;
  }

  /// Get suggested budget distribution
  Map<String, double> getBudgetDistribution(double budget) {
    return {
      'Protein': budget * 0.3, // %30 protein
      'Karbonhidrat': budget * 0.25, // %25 karbonhidrat
      'Yağ': budget * 0.15, // %15 yağ
      'Sebze/Meyve': budget * 0.2, // %20 sebze/meyve
      'Diğer': budget * 0.1, // %10 diğer
    };
  }
}
