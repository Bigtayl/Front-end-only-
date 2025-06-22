// product.dart
// Product model for the frontend-only app

/// Product model for the application
class Product {
  final int? id;
  final String name;
  final String market;
  final double price;
  final String? imageUrl;
  final String? category;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final DateTime? createdAt;

  const Product({
    this.id,
    required this.name,
    required this.market,
    required this.price,
    this.imageUrl,
    this.category,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.createdAt,
  });

  /// Create a copy of this Product with updated fields
  Product copyWith({
    int? id,
    String? name,
    String? market,
    double? price,
    String? imageUrl,
    String? category,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      market: market ?? this.market,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, market: $market, price: $price)';
  }
}
