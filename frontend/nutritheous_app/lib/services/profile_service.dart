import 'package:dio/dio.dart';
import '../models/user_profile.dart';
import '../models/user_profile_request.dart';
import 'api_client.dart';

/// Service for managing user profile
class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  /// Get current user's profile
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiClient.get('/users/profile');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load profile: ${e.message}');
    }
  }

  /// Update current user's profile
  /// Automatically calculates estimated daily calories if all fields are provided
  Future<UserProfile> updateUserProfile(UserProfileRequest request) async {
    try {
      final response = await _apiClient.put(
        '/users/profile',
        data: request.toJson(),
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }
}
