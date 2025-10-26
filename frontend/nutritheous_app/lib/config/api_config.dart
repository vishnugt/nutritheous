import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration for the Nutritheous app
class ApiConfig {
  // Base URL for the Java backend - loaded from .env file
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? _throwMissingEnvError();

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String mealsEndpoint = '/meals';
  static const String uploadMealEndpoint = '/meals/upload';
  static const String mealByIdEndpoint = '/meals'; // + /{mealId}
  static const String mealsByTypeEndpoint = '/meals/type'; // + /{mealType}
  static const String mealsByRangeEndpoint = '/meals/range';

  // Statistics endpoints
  static const String statisticsDaily = '/statistics/daily';
  static const String statisticsWeekly = '/statistics/weekly';
  static const String statisticsMonthly = '/statistics/monthly';
  static const String statisticsSummary = '/statistics/summary';
  static const String statisticsMealDistribution =
      '/statistics/meal-distribution';
  static const String statisticsPeriodicSummary =
      '/statistics/periodic-summary';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage keys
  static const String jwtTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Hive box names
  static const String mealsBoxName = 'meals';
  static const String userBoxName = 'user';
  static const String settingsBoxName = 'settings';
  static const String secureBoxName = 'secure_storage'; // For auth tokens

  // Helper function to throw error for missing environment variables
  static String _throwMissingEnvError() {
    throw Exception(
      'API_BASE_URL not found in .env file. '
      'Please create a .env file from .env.example and set the API_BASE_URL value.'
    );
  }
}
