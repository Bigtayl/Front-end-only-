// main.dart
// Uygulamanın giriş noktası. Provider ile tema ve kullanıcı yönetimi sağlar.
// MaterialApp ile uygulamanın genel temasını ve rotalarını ayarlar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'home_screen.dart';

void main() {
  // Uygulama başlatılırken Provider ile global state yönetimi sağlanır.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserData(),
        ),
      ],
      child: const BesinovaApp(),
    ),
  );
}

/// Main application widget
class BesinovaApp extends StatelessWidget {
  const BesinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Besinova',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
