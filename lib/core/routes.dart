import 'package:flutter/material.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/profile_setup_page.dart';
import '../features/session/pages/home_page.dart';
import '../features/history/pages/history_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String history = '/history';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    profileSetup: (context) => const ProfileSetupPage(),
    home: (context) => const HomePage(),
    history: (context) => const HistoryPage(),
  };
}

