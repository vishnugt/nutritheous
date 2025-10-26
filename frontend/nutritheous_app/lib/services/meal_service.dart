import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/meal.dart';
import 'api_client.dart';

/// Service for handling meal-related operations
class MealService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  MealService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all meals for the current user
  Future<List<Meal>> getMeals({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.get(ApiConfig.mealsEndpoint);

      if (response.statusCode == 200) {
        final mealsJson = response.data as List<dynamic>;
        final meals = <Meal>[];

        for (var json in mealsJson) {
          try {
            final mealData = json as Map<String, dynamic>;
            _logger.d('Parsing meal with mealType: ${mealData['mealType']}');
            final meal = Meal.fromJson(mealData);
            meals.add(meal);
          } catch (e) {
            _logger.e('Error parsing individual meal: $e, JSON: $json');
            // Skip this meal and continue
          }
        }

        _logger.i('Fetched ${meals.length} meals');
        return meals;
      } else {
        throw Exception('Failed to fetch meals: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching meals: $e');
      rethrow;
    }
  }

  /// Get a single meal by ID
  Future<Meal> getMealById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.mealsEndpoint}/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final meal = Meal.fromJson(data);
        _logger.i('Fetched meal: ${meal.id}');
        return meal;
      } else {
        throw Exception('Failed to fetch meal: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching meal: $e');
      rethrow;
    }
  }

  /// Upload a meal image and/or description to create a meal entry
  /// Either imageFile or description (or both) must be provided
  Future<Meal> uploadMeal({
    XFile? imageFile,
    required MealType mealType,
    required DateTime mealTime,
    String? description,
  }) async {
    try {
      // Validate that at least one of image or description is provided
      if (imageFile == null && (description == null || description.isEmpty)) {
        throw Exception('Either image or description must be provided');
      }

      // Convert meal type to uppercase for API
      final mealTypeStr = mealType.name.toUpperCase();

      final Response response;

      if (imageFile != null) {
        // With image - use multipart/form-data
        response = await _apiClient.uploadXFile(
          ApiConfig.uploadMealEndpoint,
          imageFile,
          fieldName: 'image',
          queryParameters: {
            'mealType': mealTypeStr,
            'mealTime': mealTime.toIso8601String(),
            if (description != null) 'description': description,
          },
        );
      } else {
        // Text-only - send empty multipart with query parameters
        final formData = FormData.fromMap({});

        response = await _apiClient.post(
          ApiConfig.uploadMealEndpoint,
          data: formData,
          queryParameters: {
            'mealType': mealTypeStr,
            'mealTime': mealTime.toIso8601String(),
            if (description != null) 'description': description,
          },
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final meal = Meal.fromJson(data);
        _logger.i('Uploaded meal: ${meal.id}');
        return meal;
      } else {
        throw Exception('Failed to upload meal: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error uploading meal: $e');
      rethrow;
    }
  }

  /// Update a meal with full nutritional data support
  Future<Meal> updateMeal({
    required String id,
    MealType? mealType,
    DateTime? mealTime,
    String? description,
    String? servingSize,
    int? calories,
    double? proteinG,
    double? fatG,
    double? saturatedFatG,
    double? carbohydratesG,
    double? fiberG,
    double? sugarG,
    double? sodiumMg,
    double? cholesterolMg,
    List<String>? ingredients,
    List<String>? allergens,
    String? healthNotes,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Basic metadata
      if (mealType != null) data['mealType'] = mealType.name.toUpperCase();
      if (mealTime != null) data['mealTime'] = mealTime.toIso8601String();
      if (description != null) data['description'] = description;
      if (servingSize != null) data['servingSize'] = servingSize;

      // Nutritional data
      if (calories != null) data['calories'] = calories;
      if (proteinG != null) data['proteinG'] = proteinG;
      if (fatG != null) data['fatG'] = fatG;
      if (saturatedFatG != null) data['saturatedFatG'] = saturatedFatG;
      if (carbohydratesG != null) data['carbohydratesG'] = carbohydratesG;
      if (fiberG != null) data['fiberG'] = fiberG;
      if (sugarG != null) data['sugarG'] = sugarG;
      if (sodiumMg != null) data['sodiumMg'] = sodiumMg;
      if (cholesterolMg != null) data['cholesterolMg'] = cholesterolMg;

      // Additional metadata
      if (ingredients != null) data['ingredients'] = ingredients;
      if (allergens != null) data['allergens'] = allergens;
      if (healthNotes != null) data['healthNotes'] = healthNotes;

      final response = await _apiClient.put(
        '${ApiConfig.mealsEndpoint}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final meal = Meal.fromJson(responseData);
        _logger.i('Updated meal: ${meal.id}');
        return meal;
      } else {
        throw Exception('Failed to update meal: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating meal: $e');
      rethrow;
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConfig.mealsEndpoint}/$id');

      if (response.statusCode == 204 || response.statusCode == 200) {
        _logger.i('Deleted meal: $id');
      } else {
        throw Exception('Failed to delete meal: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting meal: $e');
      rethrow;
    }
  }

  /// Poll for meal analysis completion
  Future<Meal> pollMealAnalysis(String id, {Duration timeout = const Duration(minutes: 5)}) async {
    final startTime = DateTime.now();
    const pollInterval = Duration(seconds: 2);

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final meal = await getMealById(id);

        if (meal.isAnalysisComplete || meal.isAnalysisFailed) {
          _logger.i('Meal analysis completed: ${meal.analysisStatus}');
          return meal;
        }

        await Future.delayed(pollInterval);
      } catch (e) {
        _logger.e('Error polling meal analysis: $e');
        rethrow;
      }
    }

    throw Exception('Meal analysis timeout after ${timeout.inMinutes} minutes');
  }

  /// Get meals by date range
  Future<List<Meal>> getMealsByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.mealsByRangeEndpoint,
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final mealsJson = response.data as List<dynamic>;
        final meals = mealsJson
            .map((json) => Meal.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Fetched ${meals.length} meals in date range');
        return meals;
      } else {
        throw Exception('Failed to fetch meals by range: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching meals by range: $e');
      rethrow;
    }
  }

  /// Get today's meals
  Future<List<Meal>> getTodayMeals() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    // Set to 23:59:59.999 of the current day to include all meals today
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return getMealsByDateRange(startOfDay, endOfDay);
  }
}
