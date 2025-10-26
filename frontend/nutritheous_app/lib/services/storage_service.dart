import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../models/meal.dart';

/// Service for handling local storage operations with Hive
class StorageService {
  final Logger _logger = Logger();

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _logger.i('Hive initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Hive: $e');

      // Try to clean up any lock files from force-close
      try {
        _logger.i('Attempting to clean up Hive...');
        await Hive.close();
        await Hive.initFlutter();
        _logger.i('Hive cleaned up and reinitialized');
      } catch (cleanupError) {
        _logger.e('Failed to clean up Hive: $cleanupError');
        rethrow;
      }
    }
  }

  /// Open all required boxes
  Future<void> openBoxes() async {
    try {
      // Try to open boxes, reuse if already open
      final futures = <Future>[];

      if (!Hive.isBoxOpen(ApiConfig.mealsBoxName)) {
        futures.add(Hive.openBox<Map>(ApiConfig.mealsBoxName));
      }
      if (!Hive.isBoxOpen(ApiConfig.userBoxName)) {
        futures.add(Hive.openBox<Map>(ApiConfig.userBoxName));
      }
      if (!Hive.isBoxOpen(ApiConfig.settingsBoxName)) {
        futures.add(Hive.openBox<Map>(ApiConfig.settingsBoxName));
      }
      // Open secure box for auth tokens (replaces flutter_secure_storage)
      if (!Hive.isBoxOpen(ApiConfig.secureBoxName)) {
        futures.add(Hive.openBox<String>(ApiConfig.secureBoxName));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      _logger.i('All Hive boxes opened successfully');
    } catch (e) {
      _logger.e('Error opening Hive boxes: $e');

      // Try to recover from corrupted boxes
      try {
        _logger.i('Attempting to recover corrupted boxes...');
        await Hive.deleteBoxFromDisk(ApiConfig.mealsBoxName);
        await Hive.deleteBoxFromDisk(ApiConfig.userBoxName);
        await Hive.deleteBoxFromDisk(ApiConfig.settingsBoxName);
        await Hive.deleteBoxFromDisk(ApiConfig.secureBoxName);

        await Future.wait([
          Hive.openBox<Map>(ApiConfig.mealsBoxName),
          Hive.openBox<Map>(ApiConfig.userBoxName),
          Hive.openBox<Map>(ApiConfig.settingsBoxName),
          Hive.openBox<String>(ApiConfig.secureBoxName),
        ]);

        _logger.i('Boxes recovered and reopened successfully');
      } catch (recoveryError) {
        _logger.e('Failed to recover boxes: $recoveryError');
        rethrow;
      }
    }
  }

  /// Get the meals box (safely)
  Box<Map>? get mealsBox {
    try {
      if (Hive.isBoxOpen(ApiConfig.mealsBoxName)) {
        return Hive.box<Map>(ApiConfig.mealsBoxName);
      }
      return null;
    } catch (e) {
      _logger.e('Error accessing meals box: $e');
      return null;
    }
  }

  /// Get the user box (safely)
  Box<Map>? get userBox {
    try {
      if (Hive.isBoxOpen(ApiConfig.userBoxName)) {
        return Hive.box<Map>(ApiConfig.userBoxName);
      }
      return null;
    } catch (e) {
      _logger.e('Error accessing user box: $e');
      return null;
    }
  }

  /// Get the settings box (safely)
  Box<Map>? get settingsBox {
    try {
      if (Hive.isBoxOpen(ApiConfig.settingsBoxName)) {
        return Hive.box<Map>(ApiConfig.settingsBoxName);
      }
      return null;
    } catch (e) {
      _logger.e('Error accessing settings box: $e');
      return null;
    }
  }

  /// Get the secure box for tokens (safely)
  Box<String>? get secureBox {
    try {
      if (Hive.isBoxOpen(ApiConfig.secureBoxName)) {
        return Hive.box<String>(ApiConfig.secureBoxName);
      }
      return null;
    } catch (e) {
      _logger.e('Error accessing secure box: $e');
      return null;
    }
  }

  // Meals operations

  /// Save meals to local storage
  Future<void> saveMeals(List<Meal> meals) async {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available, skipping save');
        return;
      }
      final mealsMap = {for (var meal in meals) meal.id: meal.toJson()};
      await box.putAll(mealsMap);
      _logger.i('Saved ${meals.length} meals to local storage');
    } catch (e) {
      _logger.e('Error saving meals: $e');
      rethrow;
    }
  }

  /// Get all cached meals
  List<Meal> getCachedMeals() {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available');
        return [];
      }

      final meals = box.values
          .map((json) => Meal.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Sort by meal time, newest first
      meals.sort((a, b) => b.mealTime.compareTo(a.mealTime));

      _logger.i('Retrieved ${meals.length} cached meals');
      return meals;
    } catch (e) {
      _logger.e('Error getting cached meals: $e');
      return [];
    }
  }

  /// Save a single meal
  Future<void> saveMeal(Meal meal) async {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available, skipping save');
        return;
      }
      await box.put(meal.id, meal.toJson());
      _logger.i('Saved meal ${meal.id} to local storage');
    } catch (e) {
      _logger.e('Error saving meal: $e');
      rethrow;
    }
  }

  /// Get a single cached meal by ID
  Meal? getCachedMeal(String id) {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available');
        return null;
      }
      final json = box.get(id);
      if (json != null) {
        return Meal.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached meal: $e');
      return null;
    }
  }

  /// Delete a meal from local storage
  Future<void> deleteMeal(String id) async {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available, skipping delete');
        return;
      }
      await box.delete(id);
      _logger.i('Deleted meal $id from local storage');
    } catch (e) {
      _logger.e('Error deleting meal: $e');
      rethrow;
    }
  }

  /// Clear all cached meals
  Future<void> clearMeals() async {
    try {
      final box = mealsBox;
      if (box == null) {
        _logger.w('Meals box not available, skipping clear');
        return;
      }
      await box.clear();
      _logger.i('Cleared all cached meals');
    } catch (e) {
      _logger.e('Error clearing meals: $e');
      rethrow;
    }
  }

  // Settings operations

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = settingsBox;
      if (box == null) {
        _logger.w('Settings box not available, skipping save');
        return;
      }
      await box.put(key, {'value': value});
      _logger.d('Saved setting $key');
    } catch (e) {
      _logger.e('Error saving setting: $e');
      rethrow;
    }
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      final box = settingsBox;
      if (box == null) {
        _logger.w('Settings box not available');
        return defaultValue;
      }
      final data = box.get(key);
      if (data != null && data.containsKey('value')) {
        return data['value'] as T;
      }
      return defaultValue;
    } catch (e) {
      _logger.e('Error getting setting: $e');
      return defaultValue;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await Hive.close();
      _logger.i('All Hive boxes closed');
    } catch (e) {
      _logger.e('Error closing Hive boxes: $e');
      rethrow;
    }
  }
}
