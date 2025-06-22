/// App-wide constants and configuration values
class AppConstants {
  // Default user values
  static const String defaultUserName = 'Kullanıcı';
  static const String defaultUserEmail = 'kullanici@besinova.com';
  static const double defaultHeight = 170.0;
  static const double defaultWeight = 70.0;
  static const int defaultAge = 25;
  static const String defaultGender = 'Erkek';
  static const String defaultActivityLevel = 'Orta';
  static const String defaultGoal = 'Sağlıklı Yaşam';
  static const String defaultAvatar = '🍏';
  static const int defaultLoginCount = 1;
  static const double defaultBudget = 5000.0;
  static const int defaultNotificationCount = 3;

  // Activity levels and multipliers
  static const Map<String, double> activityMultipliers = {
    'Hareketsiz': 1.2, // Hareketsiz yaşam (oturarak çalışma)
    'Az Aktif': 1.375, // Haftada 1-3 gün hafif egzersiz
    'Orta Aktif': 1.55, // Haftada 3-5 gün orta şiddette egzersiz
    'Çok Aktif': 1.725, // Haftada 6-7 gün yoğun egzersiz
    'Ekstra Aktif': 1.9, // Günlük yoğun egzersiz veya fiziksel iş
  };

  // Gender options
  static const List<String> genderOptions = ['Erkek', 'Kadın'];

  // Purpose options
  static const List<String> purposeOptions = [
    'Kilo vermek için',
    'Kilo almak için',
    'Sadece alışveriş önerisi için',
    'Sporcu için besin önerisi',
  ];

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI constants
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
  static const double defaultPadding = 16.0;

  // Notification limits
  static const int maxNotificationCount = 99;
  static const String maxNotificationDisplay = '99+';
}
