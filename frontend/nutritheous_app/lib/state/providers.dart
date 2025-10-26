import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import '../models/statistics.dart';
import '../models/periodic_summary_stats.dart';
import '../models/sex.dart';
import '../models/activity_level.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../services/statistics_service.dart';
import '../services/profile_service.dart';

part 'providers.g.dart';

// Service Providers

/// Provides the API client instance
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

/// Provides the AuthService instance
@riverpod
AuthService authService(AuthServiceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
}

/// Provides the MealService instance
@riverpod
MealService mealService(MealServiceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MealService(apiClient: apiClient);
}

/// Provides the StatisticsService instance
@riverpod
StatisticsService statisticsService(StatisticsServiceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StatisticsService(apiClient: apiClient);
}

/// Provides the ProfileService instance
@riverpod
ProfileService profileService(ProfileServiceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient);
}

// Auth State Providers

/// Provides the current user state
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() async {
    final authService = ref.watch(authServiceProvider);
    final user = await authService.getCurrentUser();

    // Set auth token if user exists
    if (user?.jwtToken != null) {
      final apiClient = ref.read(apiClientProvider);
      apiClient.setAuthToken(user!.jwtToken!);
    }

    return user;
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return await authService.login(email, password);
    });
  }

  /// Register a new user
  Future<void> register(
    String email,
    String password, {
    int? age,
    double? heightCm,
    double? weightKg,
    Sex? sex,
    ActivityLevel? activityLevel,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);

      return await authService.register(
        email,
        password,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        sex: sex?.apiValue,
        activityLevel: activityLevel?.apiValue,
      );
    });
  }

  /// Logout the current user
  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncValue.data(null);
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    final authService = ref.read(authServiceProvider);
    await authService.refreshToken();
    // Reload user state
    ref.invalidateSelf();
  }
}

/// Check if user is authenticated
@riverpod
Future<bool> isAuthenticated(IsAuthenticatedRef ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user != null;
}

// User Profile Providers

/// Provides the current user's profile with calorie calculations
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return await profileService.getUserProfile();
}

// Meal State Providers

/// Provides the list of meals
@riverpod
class MealsList extends _$MealsList {
  @override
  Future<List<Meal>> build() async {
    final mealService = ref.watch(mealServiceProvider);
    return await mealService.getMeals();
  }

  /// Refresh the meals list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final mealService = ref.read(mealServiceProvider);
      return await mealService.getMeals();
    });
  }

  /// Upload a new meal with optional image and/or description
  Future<Meal> uploadMeal({
    XFile? imageFile,
    required MealType mealType,
    required DateTime mealTime,
    String? description,
  }) async {
    final mealService = ref.read(mealServiceProvider);
    final meal = await mealService.uploadMeal(
      imageFile: imageFile,
      mealType: mealType,
      mealTime: mealTime,
      description: description,
    );

    // Refresh the meals list
    await refresh();

    return meal;
  }

  /// Delete a meal
  Future<void> deleteMeal(String id) async {
    final mealService = ref.read(mealServiceProvider);
    await mealService.deleteMeal(id);

    // Refresh the meals list
    await refresh();
  }

  /// Update a meal
  Future<Meal> updateMeal({
    required String id,
    MealType? mealType,
    DateTime? mealTime,
    String? description,
  }) async {
    final mealService = ref.read(mealServiceProvider);
    final meal = await mealService.updateMeal(
      id: id,
      mealType: mealType,
      mealTime: mealTime,
      description: description,
    );

    // Refresh the meals list
    await refresh();

    return meal;
  }
}

/// Provides a single meal by ID
@riverpod
Future<Meal> meal(MealRef ref, String id) async {
  final mealService = ref.watch(mealServiceProvider);
  return await mealService.getMealById(id);
}

/// Provides today's meals
@riverpod
Future<List<Meal>> todayMeals(TodayMealsRef ref) async {
  final mealService = ref.watch(mealServiceProvider);
  return await mealService.getTodayMeals();
}

/// Provides meals by date range
@riverpod
Future<List<Meal>> mealsByDateRange(
  MealsByDateRangeRef ref,
  DateTime startDate,
  DateTime endDate,
) async {
  final mealService = ref.watch(mealServiceProvider);
  return await mealService.getMealsByDateRange(startDate, endDate);
}

// Upload State Provider

/// Represents the upload state
class UploadState {
  final bool isUploading;
  final double progress;
  final String? error;
  final Meal? uploadedMeal;

  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
    this.uploadedMeal,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
    Meal? uploadedMeal,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: error,
      uploadedMeal: uploadedMeal,
    );
  }
}

/// Provides the upload state
@riverpod
class Upload extends _$Upload {
  @override
  UploadState build() {
    return const UploadState();
  }

  /// Start upload process
  void startUpload() {
    state = state.copyWith(isUploading: true, progress: 0.0, error: null);
  }

  /// Update upload progress
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  /// Complete upload
  void completeUpload(Meal meal) {
    state = state.copyWith(
      isUploading: false,
      progress: 1.0,
      uploadedMeal: meal,
    );
  }

  /// Fail upload
  void failUpload(String error) {
    state = state.copyWith(
      isUploading: false,
      error: error,
    );
  }

  /// Reset upload state
  void reset() {
    state = const UploadState();
  }
}

// Statistics Providers

/// Provides weekly nutrition statistics
@riverpod
Future<List<DailyNutritionStats>> weeklyStats(WeeklyStatsRef ref) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getWeeklyStats();
}

/// Provides monthly nutrition statistics
@riverpod
Future<List<DailyNutritionStats>> monthlyStats(MonthlyStatsRef ref) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getMonthlyStats();
}

/// Provides nutrition summary for a date range
@riverpod
Future<NutritionSummary> nutritionSummary(
  NutritionSummaryRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getNutritionSummary(
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provides daily nutrition statistics for a date range
@riverpod
Future<List<DailyNutritionStats>> dailyStats(
  DailyStatsRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getDailyStats(
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provides meal type distribution
@riverpod
Future<List<MealTypeDistribution>> mealTypeDistribution(
  MealTypeDistributionRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getMealTypeDistribution(
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provides combined summary stats for all periods (week, month, 6 months)
@riverpod
Future<PeriodicSummaryStats> periodicSummaryStats(PeriodicSummaryStatsRef ref) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return await statisticsService.getPeriodicSummaryStats();
}
