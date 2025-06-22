/// Utility functions for input validation
class Validation {
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate if string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate if number is positive
  static bool isPositive(num? value) {
    return value != null && value > 0;
  }

  /// Validate height (reasonable range: 100-250 cm)
  static bool isValidHeight(double? height) {
    return height != null && height >= 100 && height <= 250;
  }

  /// Validate weight (reasonable range: 30-300 kg)
  static bool isValidWeight(double? weight) {
    return weight != null && weight >= 30 && weight <= 300;
  }

  /// Validate age (reasonable range: 10-120 years)
  static bool isValidAge(int? age) {
    return age != null && age >= 10 && age <= 120;
  }

  /// Validate budget (must be positive)
  static bool isValidBudget(double? budget) {
    return budget != null && budget >= 0;
  }

  /// Get validation error message for height
  static String? getHeightError(double? height) {
    if (height == null || height == 0) {
      return 'Boy değeri gerekli';
    }
    if (!isValidHeight(height)) {
      return 'Geçerli bir boy değeri girin (100-250 cm)';
    }
    return null;
  }

  /// Get validation error message for weight
  static String? getWeightError(double? weight) {
    if (weight == null || weight == 0) {
      return 'Kilo değeri gerekli';
    }
    if (!isValidWeight(weight)) {
      return 'Geçerli bir kilo değeri girin (30-300 kg)';
    }
    return null;
  }

  /// Get validation error message for age
  static String? getAgeError(int? age) {
    if (age == null || age == 0) {
      return 'Yaş değeri gerekli';
    }
    if (!isValidAge(age)) {
      return 'Geçerli bir yaş değeri girin (10-120)';
    }
    return null;
  }

  /// Get validation error message for email
  static String? getEmailError(String? email) {
    if (!isNotEmpty(email)) {
      return 'E-posta adresi gerekli';
    }
    if (!isValidEmail(email!)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Get validation error message for name
  static String? getNameError(String? name) {
    if (!isNotEmpty(name)) {
      return 'İsim gerekli';
    }
    if (name!.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }
    return null;
  }
}
