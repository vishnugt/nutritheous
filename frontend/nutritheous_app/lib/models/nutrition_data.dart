import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'nutrition_data.g.dart';

/// Represents comprehensive nutritional information for a meal (matches API MealResponse fields)
@JsonSerializable()
class NutritionData extends Equatable {
  final double calories;

  @JsonKey(name: 'protein_g')
  final double proteinG;

  @JsonKey(name: 'fat_g')
  final double fatG;

  @JsonKey(name: 'saturated_fat_g')
  final double? saturatedFatG;

  @JsonKey(name: 'carbohydrates_g')
  final double carbohydratesG;

  @JsonKey(name: 'fiber_g')
  final double? fiberG;

  @JsonKey(name: 'sugar_g')
  final double? sugarG;

  @JsonKey(name: 'sodium_mg')
  final double? sodiumMg;

  @JsonKey(name: 'cholesterol_mg')
  final double? cholesterolMg;

  @JsonKey(name: 'serving_size')
  final String? servingSize;

  @JsonKey(name: 'health_notes')
  final String? healthNotes;

  final List<String>? ingredients;

  final List<String>? allergens;

  const NutritionData({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbohydratesG,
    this.saturatedFatG,
    this.fiberG,
    this.sugarG,
    this.sodiumMg,
    this.cholesterolMg,
    this.servingSize,
    this.healthNotes,
    this.ingredients,
    this.allergens,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) =>
      _$NutritionDataFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionDataToJson(this);

  /// Create an empty NutritionData instance
  factory NutritionData.empty() => const NutritionData(
        calories: 0,
        proteinG: 0,
        fatG: 0,
        carbohydratesG: 0,
      );

  @override
  List<Object?> get props => [
        calories,
        proteinG,
        fatG,
        saturatedFatG,
        carbohydratesG,
        fiberG,
        sugarG,
        sodiumMg,
        cholesterolMg,
        servingSize,
        healthNotes,
        ingredients,
        allergens,
      ];

  NutritionData copyWith({
    double? calories,
    double? proteinG,
    double? fatG,
    double? saturatedFatG,
    double? carbohydratesG,
    double? fiberG,
    double? sugarG,
    double? sodiumMg,
    double? cholesterolMg,
    String? servingSize,
    String? healthNotes,
    List<String>? ingredients,
    List<String>? allergens,
  }) {
    return NutritionData(
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      saturatedFatG: saturatedFatG ?? this.saturatedFatG,
      carbohydratesG: carbohydratesG ?? this.carbohydratesG,
      fiberG: fiberG ?? this.fiberG,
      sugarG: sugarG ?? this.sugarG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      cholesterolMg: cholesterolMg ?? this.cholesterolMg,
      servingSize: servingSize ?? this.servingSize,
      healthNotes: healthNotes ?? this.healthNotes,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
    );
  }

  // Backward compatibility getters
  double get protein => proteinG;
  double get fat => fatG;
  double get carbs => carbohydratesG;

  /// Full AI analysis as a map (for backward compatibility)
  Map<String, dynamic>? get rawAnalysis => null;
}
