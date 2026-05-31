import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static bool get isDev => (dotenv.env['IS_DEV'] ?? 'false').toLowerCase() == 'true';
}

