# Besinova - Frontend-Only Flutter App

A clean, frontend-only Flutter application for nutrition and health management. This is a presentation-focused UI project with no backend dependencies.

## 🎯 Features

- **Pure Frontend**: No backend, Firebase, authentication, or API dependencies
- **Mock Data**: All data is simulated using local mock services
- **Clean Architecture**: Simplified, readable codebase focused on UI/UX
- **Responsive Design**: Beautiful, modern UI with smooth animations
- **Local Storage**: Uses SharedPreferences for basic data persistence

## 📱 Screens

- **Home Screen**: Main dashboard with quick access to features
- **Nutrition Screen**: Food recommendations and macro tracking
- **Analytics Screen**: BMI, BMR, TDEE calculations and health analysis
- **Shopping List**: Grocery list management
- **Profile & Settings**: User preferences and app configuration

## 🏗️ Architecture

```
lib/
├── core/           # App constants, themes, utilities
├── models/         # Data models (Product, etc.)
├── providers/      # State management (UserProvider, ThemeProvider)
├── screens/        # UI screens
├── services/       # Mock data services
└── widgets/        # Reusable UI components
```

## 🚀 Getting Started

1. **Prerequisites**
   - Flutter SDK (>=3.2.3)
   - Dart SDK

2. **Installation**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Dependencies**
   - `provider`: State management
   - `shared_preferences`: Local data storage
   - `flutter_staggered_animations`: UI animations
   - `google_fonts`: Typography
   - `lottie`: Animated assets

## 🎨 Design Philosophy

- **UI/UX First**: All visual elements preserved exactly as designed
- **Zero Backend**: No external dependencies or API calls
- **Performance**: Optimized for smooth, responsive interactions
- **Simplicity**: Clean, maintainable code structure

## 📊 Data Flow

1. **Mock Services**: Provide sample data for all features
2. **Local Storage**: Save user preferences and favorites
3. **State Management**: Provider pattern for app-wide state
4. **UI Components**: Reusable widgets for consistent design

## 🔧 Development

This app is designed as a presentation layer that can be easily extended with real backend services in the future. All mock services can be replaced with actual API calls without changing the UI layer.

## 📝 License

This project is for demonstration purposes.
