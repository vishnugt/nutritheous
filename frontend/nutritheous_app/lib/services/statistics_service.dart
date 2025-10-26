import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/statistics.dart';
import '../models/periodic_summary_stats.dart';
import 'api_client.dart';

/// Service for handling nutrition statistics operations
class StatisticsService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  StatisticsService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get daily nutrition statistics for a date range
  Future<List<DailyNutritionStats>> getDailyStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }
      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      final response = await _apiClient.get(
        ApiConfig.statisticsDaily,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final statsJson = response.data as List<dynamic>;
        final stats = statsJson
            .map((json) => DailyNutritionStats.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Fetched ${stats.length} daily stats');
        return stats;
      } else {
        throw Exception('Failed to fetch daily stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching daily stats: $e');
      rethrow;
    }
  }

  /// Get weekly nutrition statistics (past 7 days)
  Future<List<DailyNutritionStats>> getWeeklyStats() async {
    try {
      final response = await _apiClient.get(ApiConfig.statisticsWeekly);

      if (response.statusCode == 200) {
        final statsJson = response.data as List<dynamic>;
        final stats = statsJson
            .map((json) => DailyNutritionStats.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Fetched weekly stats: ${stats.length} days');
        return stats;
      } else {
        throw Exception('Failed to fetch weekly stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching weekly stats: $e');
      rethrow;
    }
  }

  /// Get monthly nutrition statistics (past 30 days)
  Future<List<DailyNutritionStats>> getMonthlyStats() async {
    try {
      final response = await _apiClient.get(ApiConfig.statisticsMonthly);

      if (response.statusCode == 200) {
        final statsJson = response.data as List<dynamic>;
        final stats = statsJson
            .map((json) => DailyNutritionStats.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Fetched monthly stats: ${stats.length} days');
        return stats;
      } else {
        throw Exception('Failed to fetch monthly stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching monthly stats: $e');
      rethrow;
    }
  }

  /// Get comprehensive nutrition summary
  Future<NutritionSummary> getNutritionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }
      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      final response = await _apiClient.get(
        ApiConfig.statisticsSummary,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final summary = NutritionSummary.fromJson(data);

        _logger.i('Fetched nutrition summary: ${summary.totalMeals} meals');
        return summary;
      } else {
        throw Exception('Failed to fetch nutrition summary: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching nutrition summary: $e');
      rethrow;
    }
  }

  /// Get meal type distribution
  Future<List<MealTypeDistribution>> getMealTypeDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }
      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      final response = await _apiClient.get(
        ApiConfig.statisticsMealDistribution,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final distributionJson = response.data as List<dynamic>;
        final distribution = distributionJson
            .map((json) => MealTypeDistribution.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Fetched meal type distribution: ${distribution.length} types');
        return distribution;
      } else {
        throw Exception('Failed to fetch meal distribution: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching meal distribution: $e');
      rethrow;
    }
  }

  /// Get combined summary stats for all periods (week, month, 6 months)
  Future<PeriodicSummaryStats> getPeriodicSummaryStats() async {
    try {
      final response = await _apiClient.get(ApiConfig.statisticsPeriodicSummary);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final stats = PeriodicSummaryStats.fromJson(data);

        _logger.i('Fetched periodic summary stats');
        return stats;
      } else {
        throw Exception('Failed to fetch periodic summary stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching periodic summary stats: $e');
      rethrow;
    }
  }
}
