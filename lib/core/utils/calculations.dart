/// Utility functions for health and nutrition calculations
class Calculations {
  /// Calculate Body Mass Index (BMI)
  /// Formula: weight (kg) / height (m)²
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  /// Formula: (10 × weight) + (6.25 × height) - (5 × age) + 5 (for men)
  /// Formula: (10 × weight) + (6.25 × height) - (5 × age) - 161 (for women)
  static double calculateBMR(
      double weight, double height, int age, String gender) {
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    return gender.toLowerCase() == 'erkek' ? bmr + 5 : bmr - 161;
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  /// Formula: BMR × Activity Multiplier
  static double calculateTDEE(double bmr, double activityMultiplier) {
    return bmr * activityMultiplier;
  }

  /// Get BMI category based on BMI value
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  /// Get BMI recommendation based on category
  static String getBMIRecommendation(String category) {
    switch (category) {
      case 'Zayıf':
        return 'Sağlıklı kilo almak için protein ve karbonhidrat açısından zengin besinler tüketin.';
      case 'Normal':
        return 'Mevcut kilonuzu korumak için dengeli beslenmeye devam edin.';
      case 'Fazla Kilolu':
        return 'Kilo vermek için kalori açığı oluşturun ve düzenli egzersiz yapın.';
      case 'Obez':
        return 'Doktor kontrolünde sağlıklı bir diyet programı uygulayın.';
      default:
        return 'Sağlıklı beslenme için uzman tavsiyesi alın.';
    }
  }

  /// Calculate daily calorie needs based on goal
  static double calculateDailyCalories(double tdee, String goal) {
    switch (goal) {
      case 'Kilo vermek için':
        return tdee - 500; // 500 calorie deficit
      case 'Kilo almak için':
        return tdee + 300; // 300 calorie surplus
      default:
        return tdee; // Maintenance
    }
  }
}
