import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// Service for handling authentication operations
/// Uses Hive for secure storage instead of flutter_secure_storage to avoid iOS crashes
class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final Logger _logger = Logger();

  AuthService({
    required ApiClient apiClient,
    StorageService? storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService ?? StorageService();

  /// Login with email and password
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = User.fromJson(data);

        // Store token and user data in Hive
        if (user.token != null) {
          await _saveToken(ApiConfig.jwtTokenKey, user.token!);
        }
        await _saveUserData(user);

        // Set auth token for future requests
        if (user.token != null) {
          _apiClient.setAuthToken(user.token!);
        }

        _logger.i('Login successful for user: ${user.email}');
        return user;
      } else {
        throw Exception('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  /// Register a new user
  Future<User> register(
    String email,
    String password, {
    int? age,
    double? heightCm,
    double? weightKg,
    String? sex,
    String? activityLevel,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'email': email,
        'password': password,
      };

      // Add profile fields if provided
      if (age != null) requestData['age'] = age;
      if (heightCm != null) requestData['heightCm'] = heightCm;
      if (weightKg != null) requestData['weightKg'] = weightKg;
      if (sex != null) requestData['sex'] = sex;
      if (activityLevel != null) requestData['activityLevel'] = activityLevel;

      final response = await _apiClient.post(
        ApiConfig.registerEndpoint,
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = User.fromJson(data);

        // Store token and user data in Hive
        if (user.token != null) {
          await _saveToken(ApiConfig.jwtTokenKey, user.token!);
        }
        await _saveUserData(user);

        // Set auth token for future requests
        if (user.token != null) {
          _apiClient.setAuthToken(user.token!);
        }

        _logger.i('Registration successful for user: ${user.email}');
        return user;
      } else {
        throw Exception('Registration failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      rethrow;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _clearUserData();
      _apiClient.clearAuthToken();
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
      rethrow;
    }
  }

  /// Get stored JWT token
  Future<String?> getJwtToken() async {
    try {
      final box = _storageService.secureBox;
      if (box == null) {
        _logger.w('Secure box not available');
        return null;
      }
      return box.get(ApiConfig.jwtTokenKey);
    } catch (e) {
      _logger.e('Error reading JWT token from storage: $e');
      return null;
    }
  }

  /// Get stored user data
  Future<User?> getCurrentUser() async {
    try {
      final box = _storageService.secureBox;
      if (box == null) {
        _logger.w('Secure box not available');
        return null;
      }

      final userId = box.get(ApiConfig.userIdKey);
      final userEmail = box.get(ApiConfig.userEmailKey);
      final token = await getJwtToken();
      final role = box.get('user_role');

      if (userId != null && userEmail != null) {
        return User(
          userId: userId,
          email: userEmail,
          token: token,
          role: role,
        );
      }
      return null;
    } catch (e) {
      _logger.w('Unable to read user data from storage: $e');
      return null;
    }
  }

  /// Refresh the JWT token (not implemented in current API)
  Future<String> refreshToken() async {
    throw UnimplementedError('Token refresh is not supported by the current API');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getJwtToken();
    return token != null;
  }

  // Private helper methods
  Future<void> _saveToken(String key, String value) async {
    try {
      final box = _storageService.secureBox;
      if (box != null) {
        await box.put(key, value);
      } else {
        _logger.w('Secure box not available for saving token');
      }
    } catch (e) {
      _logger.e('Error saving token: $e');
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      final box = _storageService.secureBox;
      if (box != null) {
        await box.put(ApiConfig.userIdKey, user.userId);
        await box.put(ApiConfig.userEmailKey, user.email);
        if (user.role != null) {
          await box.put('user_role', user.role!);
        }
      } else {
        _logger.w('Secure box not available for saving user data');
      }
    } catch (e) {
      _logger.e('Error saving user data: $e');
    }
  }

  Future<void> _clearUserData() async {
    try {
      final box = _storageService.secureBox;
      if (box != null) {
        await box.delete(ApiConfig.userIdKey);
        await box.delete(ApiConfig.userEmailKey);
        await box.delete(ApiConfig.jwtTokenKey);
        await box.delete('user_role');
      } else {
        _logger.w('Secure box not available for clearing user data');
      }
    } catch (e) {
      _logger.e('Error clearing user data: $e');
    }
  }
}
