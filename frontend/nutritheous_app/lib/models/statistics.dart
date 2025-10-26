import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'statistics.g.dart';

/// Daily nutrition statistics for a single day
@JsonSerializable()
class DailyNutritionStats extends Equatable {
  /// Date of the statistics
  final DateTime date;

  /// Total calories consumed
  final int totalCalories;

  /// Total protein in grams
  @JsonKey(name: 'totalProteinG')
  final double totalProteinG;

  /// Total fat in grams
  @JsonKey(name: 'totalFatG')
  final double totalFatG;

  /// Total saturated fat in grams
  @JsonKey(name: 'totalSaturatedFatG')
  final double? totalSaturatedFatG;

  /// Total carbohydrates in grams
  @JsonKey(name: 'totalCarbohydratesG')
  final double totalCarbohydratesG;

  /// Total fiber in grams
  @JsonKey(name: 'totalFiberG')
  final double? totalFiberG;

  /// Total sugar in grams
  @JsonKey(name: 'totalSugarG')
  final double? totalSugarG;

  /// Total sodium in milligrams
  @JsonKey(name: 'totalSodiumMg')
  final double? totalSodiumMg;

  /// Total cholesterol in milligrams
  @JsonKey(name: 'totalCholesterolMg')
  final double? totalCholesterolMg;

  /// Number of meals on this day
  final int mealCount;

  const DailyNutritionStats({
    required this.date,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalFatG,
    required this.totalCarbohydratesG,
    required this.mealCount,
    this.totalSaturatedFatG,
    this.totalFiberG,
    this.totalSugarG,
    this.totalSodiumMg,
    this.totalCholesterolMg,
  });

  factory DailyNutritionStats.fromJson(Map<String, dynamic> json) =>
      _$DailyNutritionStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyNutritionStatsToJson(this);

  @override
  List<Object?> get props => [
        date,
        totalCalories,
        totalProteinG,
        totalFatG,
        totalSaturatedFatG,
        totalCarbohydratesG,
        totalFiberG,
        totalSugarG,
        totalSodiumMg,
        totalCholesterolMg,
        mealCount,
      ];
}

/// Distribution of meals by type
@JsonSerializable()
class MealTypeDistribution extends Equatable {
  /// Meal type (BREAKFAST, LUNCH, DINNER, SNACK)
  final String mealType;

  /// Number of meals of this type
  final int count;

  /// Percentage of total meals
  final double percentage;

  const MealTypeDistribution({
    required this.mealType,
    required this.count,
    required this.percentage,
  });

  factory MealTypeDistribution.fromJson(Map<String, dynamic> json) =>
      _$MealTypeDistributionFromJson(json);

  Map<String, dynamic> toJson() => _$MealTypeDistributionToJson(this);

  @override
  List<Object?> get props => [mealType, count, percentage];
}

/// Comprehensive nutrition summary over a time period
@JsonSerializable()
class NutritionSummary extends Equatable {
  /// Total number of meals tracked
  final int totalMeals;

  /// Average calories per day
  final double avgCaloriesPerDay;

  /// Average protein per day in grams
  final double avgProteinPerDay;

  /// Average carbohydrates per day in grams
  final double avgCarbsPerDay;

  /// Average fat per day in grams
  final double avgFatPerDay;

  /// Daily nutrition breakdown (for plotting)
  final List<DailyNutritionStats> dailyStats;

  /// Distribution of meals by type
  final List<MealTypeDistribution> mealTypeDistribution;

  const NutritionSummary({
    required this.totalMeals,
    required this.avgCaloriesPerDay,
    required this.avgProteinPerDay,
    required this.avgCarbsPerDay,
    required this.avgFatPerDay,
    required this.dailyStats,
    required this.mealTypeDistribution,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) =>
      _$NutritionSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionSummaryToJson(this);

  @override
  List<Object?> get props => [
        totalMeals,
        avgCaloriesPerDay,
        avgProteinPerDay,
        avgCarbsPerDay,
        avgFatPerDay,
        dailyStats,
        mealTypeDistribution,
      ];

  /// Calculate total nutrition for the period
  int get totalCalories => dailyStats.fold(0, (sum, day) => sum + day.totalCalories);
  double get totalProtein => dailyStats.fold(0.0, (sum, day) => sum + day.totalProteinG);
  double get totalCarbs => dailyStats.fold(0.0, (sum, day) => sum + day.totalCarbohydratesG);
  double get totalFat => dailyStats.fold(0.0, (sum, day) => sum + day.totalFatG);

  /// Get the day with highest calories
  DailyNutritionStats? get highestCalorieDay {
    if (dailyStats.isEmpty) return null;
    return dailyStats.reduce((a, b) => a.totalCalories > b.totalCalories ? a : b);
  }

  /// Get the day with most meals
  DailyNutritionStats? get mostMealsDay {
    if (dailyStats.isEmpty) return null;
    return dailyStats.reduce((a, b) => a.mealCount > b.mealCount ? a : b);
  }

  /// Get most common meal type
  MealTypeDistribution? get mostCommonMealType {
    if (mealTypeDistribution.isEmpty) return null;
    return mealTypeDistribution.reduce((a, b) => a.count > b.count ? a : b);
  }
}
