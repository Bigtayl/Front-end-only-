// mock_data_service.dart
// Mock data service for frontend-only version of the app
// Provides sample data for the UI

import '../models/product.dart';

/// Mock data service that provides sample data for the frontend-only app
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  /// Get sample products for the app
  List<Product> getSampleProducts() {
    return [
      Product(
        id: 1,
        name: 'Tavuk Göğsü',
        market: 'Migros',
        price: 89.90,
        imageUrl:
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
        category: 'Protein',
        caloriesPer100g: 165.0,
        proteinPer100g: 31.0,
        carbsPer100g: 0.0,
        fatPer100g: 3.6,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: 2,
        name: 'Somon Balığı',
        market: 'Carrefoursa',
        price: 129.90,
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
        category: 'Protein',
        caloriesPer100g: 208.0,
        proteinPer100g: 25.0,
        carbsPer100g: 0.0,
        fatPer100g: 12.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: 3,
        name: 'Yulaf Ezmesi',
        market: 'BİM',
        price: 45.90,
        imageUrl:
            'https://images.unsplash.com/photo-1612507093780-7056e2990d1f?w=400',
        category: 'Karbonhidrat',
        caloriesPer100g: 389.0,
        proteinPer100g: 16.9,
        carbsPer100g: 66.3,
        fatPer100g: 6.9,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: 4,
        name: 'Tam Yağlı Süt',
        market: 'Migros',
        price: 32.50,
        imageUrl:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
        category: 'Protein',
        caloriesPer100g: 61.0,
        proteinPer100g: 3.2,
        carbsPer100g: 4.8,
        fatPer100g: 3.3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: 5,
        name: 'Domates',
        market: 'Carrefoursa',
        price: 18.90,
        imageUrl:
            'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400',
        category: 'Sebze/Meyve',
        caloriesPer100g: 18.0,
        proteinPer100g: 0.9,
        carbsPer100g: 3.9,
        fatPer100g: 0.2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: 6,
        name: 'Muz',
        market: 'BİM',
        price: 24.90,
        imageUrl:
            'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
        category: 'Sebze/Meyve',
        caloriesPer100g: 89.0,
        proteinPer100g: 1.1,
        carbsPer100g: 22.8,
        fatPer100g: 0.3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: 7,
        name: 'Zeytinyağı',
        market: 'Migros',
        price: 89.90,
        imageUrl:
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400',
        category: 'Yağ',
        caloriesPer100g: 884.0,
        proteinPer100g: 0.0,
        carbsPer100g: 0.0,
        fatPer100g: 100.0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: 8,
        name: 'Kahverengi Pirinç',
        market: 'Carrefoursa',
        price: 55.90,
        imageUrl:
            'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
        category: 'Karbonhidrat',
        caloriesPer100g: 111.0,
        proteinPer100g: 2.6,
        carbsPer100g: 23.0,
        fatPer100g: 0.9,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: 9,
        name: 'Yumurta (15\'li)',
        market: 'BİM',
        price: 67.90,
        imageUrl:
            'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400',
        category: 'Protein',
        caloriesPer100g: 155.0,
        proteinPer100g: 12.6,
        carbsPer100g: 1.1,
        fatPer100g: 11.3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: 10,
        name: 'Brokoli',
        market: 'Migros',
        price: 28.90,
        imageUrl:
            'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400',
        category: 'Sebze/Meyve',
        caloriesPer100g: 34.0,
        proteinPer100g: 2.8,
        carbsPer100g: 7.0,
        fatPer100g: 0.4,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Get sample shopping list items
  List<Map<String, dynamic>> getSampleShoppingList() {
    return [
      {
        'id': 1,
        'name': 'Domates',
        'quantity': 2,
        'unit': 'kg',
        'price': 18.90,
        'market': 'Carrefoursa',
        'image':
            'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400',
        'isCompleted': false,
      },
      {
        'id': 2,
        'name': 'Tavuk Göğsü',
        'quantity': 1,
        'unit': 'kg',
        'price': 89.90,
        'market': 'BİM',
        'image':
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
        'isCompleted': false,
      },
      {
        'id': 3,
        'name': 'Süt',
        'quantity': 2,
        'unit': 'L',
        'price': 32.50,
        'market': 'Migros',
        'image':
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
        'isCompleted': true,
      },
    ];
  }

  /// Get sample nutrition tips
  List<Map<String, dynamic>> getSampleNutritionTips() {
    return [
      {
        'id': 1,
        'title': 'Günlük Su Tüketimi',
        'description': 'Günde en az 2-2.5 litre su içmeyi unutmayın.',
        'icon': '💧',
        'category': 'Hidrasyon',
      },
      {
        'id': 2,
        'title': 'Protein Dengesi',
        'description':
            'Her öğünde protein içeren besinler tüketmeye özen gösterin.',
        'icon': '🥩',
        'category': 'Protein',
      },
      {
        'id': 3,
        'title': 'Sebze Tüketimi',
        'description': 'Günde en az 5 porsiyon sebze ve meyve tüketin.',
        'icon': '🥬',
        'category': 'Sebze/Meyve',
      },
      {
        'id': 4,
        'title': 'Kahvaltı Önemi',
        'description': 'Güne sağlıklı bir kahvaltı ile başlayın.',
        'icon': '🍳',
        'category': 'Genel',
      },
    ];
  }

  /// Get sample analytics data
  Map<String, dynamic> getSampleAnalyticsData() {
    return {
      'weeklyCalories': [2100, 1950, 2200, 1850, 2300, 2000, 2150],
      'weeklyProtein': [85, 78, 92, 75, 88, 82, 90],
      'weeklyCarbs': [250, 230, 270, 220, 280, 240, 260],
      'weeklyFat': [65, 58, 72, 55, 68, 62, 70],
      'budgetUsage': 78.5,
      'goalProgress': 65.0,
      'topCategories': [
        {'name': 'Protein', 'percentage': 35},
        {'name': 'Karbonhidrat', 'percentage': 30},
        {'name': 'Sebze/Meyve', 'percentage': 20},
        {'name': 'Yağ', 'percentage': 15},
      ],
    };
  }
}
