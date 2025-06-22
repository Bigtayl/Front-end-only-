import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/product.dart';
import 'dart:convert';

/// Provider for managing user data and preferences (Frontend-only version)
class UserProvider with ChangeNotifier {
  // User information
  String _name = '';
  String _email = '';
  double _height = 0;
  double _weight = 0;
  int _age = 0;
  String _gender = '';
  String _activityLevel = '';
  String _goal = '';
  String _avatar = AppConstants.defaultAvatar;
  int _loginCount = 0;
  String _lastLogin = '';
  int _completedGoals = 0;
  double _budget = AppConstants.defaultBudget;
  int _notificationCount = AppConstants.defaultNotificationCount;

  // Macro values
  double _tdee = 2000.0;
  double _protein = 150.0; // (2000 * 0.30) / 4 = 150g
  double _carb = 200.0; // (2000 * 0.40) / 4 = 200g
  double _fat = 67.0; // (2000 * 0.30) / 9 = 67g

  // Favorites list
  List<Product> _favorites = [];

  // Getters
  String get name => _name;
  String get email => _email;
  double get height => _height;
  double get weight => _weight;
  int get age => _age;
  String get gender => _gender;
  String get activityLevel => _activityLevel;
  String get goal => _goal;
  String get avatar => _avatar;
  int get loginCount => _loginCount;
  String get lastLogin => _lastLogin;
  int get completedGoals => _completedGoals;
  double get budget => _budget;
  int get notificationCount => _notificationCount;
  List<Product> get favorites => _favorites;

  // Macro getters
  double get tdee => _tdee;
  double get protein => _protein;
  double get carb => _carb;
  double get fat => _fat;

  /// Check if a product is in favorites
  bool isFavorite(Product product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  /// Add product to favorites
  Future<void> addToFavorites(Product product) async {
    if (!isFavorite(product)) {
      _favorites.add(product);
      await _saveFavorites();
      notifyListeners();
    }
  }

  /// Remove product from favorites
  Future<void> removeFromFavorites(Product product) async {
    _favorites.removeWhere((fav) => fav.id == product.id);
    await _saveFavorites();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Product product) async {
    if (isFavorite(product)) {
      await removeFromFavorites(product);
    } else {
      await addToFavorites(product);
    }
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // For frontend-only app, we'll store a simple list of product IDs
    final favoriteIds = _favorites.map((product) => product.id).toList();
    await prefs.setString('favoriteIds', jsonEncode(favoriteIds));
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIdsString = prefs.getString('favoriteIds');
    if (favoriteIdsString != null && favoriteIdsString.isNotEmpty) {
      try {
        final List<dynamic> favoriteIds = jsonDecode(favoriteIdsString);
        // For simplicity, we'll create basic product objects from IDs
        // In a real app, you'd fetch the full product data
        _favorites = favoriteIds
            .map((id) => Product(
                  id: id,
                  name: 'Product $id',
                  market: 'Market',
                  price: 0.0,
                ))
            .toList();
      } catch (e) {
        // If there's any error, clear the corrupted data and start fresh
        await prefs.remove('favoriteIds');
        _favorites = [];
      }
    } else {
      _favorites = [];
    }
  }

  /// Update avatar and save to storage
  void setAvatar(String newAvatar) {
    _avatar = newAvatar;
    saveUserData(avatar: newAvatar);
    notifyListeners();
  }

  /// Update name and save to storage
  void setName(String newName) {
    _name = newName;
    saveUserData(name: newName);
    notifyListeners();
  }

  /// Update budget and save to storage
  void setBudget(double newBudget) {
    _budget = newBudget;
    saveUserData(budget: newBudget);
    notifyListeners();
  }

  /// Increment login count and save to storage
  void incrementLoginCount() async {
    _loginCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginCount', _loginCount);
    notifyListeners();
  }

  /// Update last login time and save to storage
  void updateLastLogin(String dateTime) async {
    _lastLogin = dateTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastLogin', dateTime);
    notifyListeners();
  }

  /// Increment completed goals count and save to storage
  void incrementCompletedGoals() async {
    _completedGoals++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedGoals', _completedGoals);
    notifyListeners();
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteIds');
    notifyListeners();
  }

  /// Calculate and update macro values based on TDEE
  Future<void> updateMacrosFromTDEE(double tdee) async {
    // Calculate macros using the formula:
    // Protein: 30% of total calories → divide by 4 kcal/g
    // Fat: 30% of total calories → divide by 9 kcal/g
    // Carbohydrate: 40% of total calories → divide by 4 kcal/g
    final double proteinGrams = (tdee * 0.30) / 4;
    final double fatGrams = (tdee * 0.30) / 9;
    final double carbGrams = (tdee * 0.40) / 4;

    await saveUserData(
      tdee: tdee,
      protein: proteinGrams,
      carb: carbGrams,
      fat: fatGrams,
    );
  }

  /// Load user data from SharedPreferences (with mock defaults)
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load from SharedPreferences or use mock defaults
      _name = prefs.getString('name') ?? 'Demo Kullanıcı';
      _email = prefs.getString('email') ?? 'demo@besinova.com';
      _height = prefs.getDouble('height') ?? 170.0;
      _weight = prefs.getDouble('weight') ?? 70.0;
      _age = prefs.getInt('age') ?? 25;
      _gender = prefs.getString('gender') ?? 'Erkek';
      _activityLevel = prefs.getString('activityLevel') ?? 'Orta';
      _goal = prefs.getString('goal') ?? 'Sağlıklı Yaşam';
      _avatar = prefs.getString('avatar') ?? AppConstants.defaultAvatar;
      _loginCount = prefs.getInt('loginCount') ?? 1;
      _lastLogin = prefs.getString('lastLogin') ?? DateTime.now().toString();
      _completedGoals = prefs.getInt('completedGoals') ?? 0;
      _budget = prefs.getDouble('budget') ?? 1000.0;
      _notificationCount = prefs.getInt('notificationCount') ?? 3;

      // Load macro values
      _tdee = prefs.getDouble('tdee') ?? 2000.0;
      _protein = prefs.getDouble('protein') ?? 150.0;
      _carb = prefs.getDouble('carb') ?? 200.0;
      _fat = prefs.getDouble('fat') ?? 67.0;

      // Load favorites
      await _loadFavorites();
    } catch (e) {
      // If there's any error loading user data, reset to defaults
      await resetToDefaults();
    }

    notifyListeners();
  }

  /// Save user data to SharedPreferences
  Future<void> saveUserData({
    String? name,
    String? email,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    String? avatar,
    int? loginCount,
    String? lastLogin,
    int? completedGoals,
    double? budget,
    int? notificationCount,
    double? tdee,
    double? protein,
    double? carb,
    double? fat,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      _name = name;
      await prefs.setString('name', name);
    }
    if (email != null) {
      _email = email;
      await prefs.setString('email', email);
    }
    if (height != null) {
      _height = height;
      await prefs.setDouble('height', height);
    }
    if (weight != null) {
      _weight = weight;
      await prefs.setDouble('weight', weight);
    }
    if (age != null) {
      _age = age;
      await prefs.setInt('age', age);
    }
    if (gender != null) {
      _gender = gender;
      await prefs.setString('gender', gender);
    }
    if (activityLevel != null) {
      _activityLevel = activityLevel;
      await prefs.setString('activityLevel', activityLevel);
    }
    if (goal != null) {
      _goal = goal;
      await prefs.setString('goal', goal);
    }
    if (avatar != null) {
      _avatar = avatar;
      await prefs.setString('avatar', avatar);
    }
    if (loginCount != null) {
      _loginCount = loginCount;
      await prefs.setInt('loginCount', loginCount);
    }
    if (lastLogin != null) {
      _lastLogin = lastLogin;
      await prefs.setString('lastLogin', lastLogin);
    }
    if (completedGoals != null) {
      _completedGoals = completedGoals;
      await prefs.setInt('completedGoals', completedGoals);
    }
    if (budget != null) {
      _budget = budget;
      await prefs.setDouble('budget', budget);
    }
    if (notificationCount != null) {
      _notificationCount = notificationCount;
      await prefs.setInt('notificationCount', notificationCount);
    }
    if (tdee != null) {
      _tdee = tdee;
      await prefs.setDouble('tdee', tdee);
    }
    if (protein != null) {
      _protein = protein;
      await prefs.setDouble('protein', protein);
    }
    if (carb != null) {
      _carb = carb;
      await prefs.setDouble('carb', carb);
    }
    if (fat != null) {
      _fat = fat;
      await prefs.setDouble('fat', fat);
    }
    notifyListeners();
  }

  /// Reset user data to defaults (for demo purposes)
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await loadUserData();
  }
}
