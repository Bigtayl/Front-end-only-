import 'package:flutter/material.dart';

/// Provider for managing application theme (dark/light mode)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark themes
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set theme mode directly
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
