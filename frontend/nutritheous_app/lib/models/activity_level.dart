import 'package:json_annotation/json_annotation.dart';

/// Activity level for calculating total daily energy expenditure (TDEE)
enum ActivityLevel {
  @JsonValue('SEDENTARY')
  sedentary,
  @JsonValue('LIGHTLY_ACTIVE')
  lightlyActive,
  @JsonValue('MODERATELY_ACTIVE')
  moderatelyActive,
  @JsonValue('VERY_ACTIVE')
  veryActive,
  @JsonValue('EXTREMELY_ACTIVE')
  extremelyActive,
}

extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extremelyActive:
        return 'Extremely Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.extremelyActive:
        return 'Very hard exercise and physical job';
    }
  }

  String get apiValue {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'SEDENTARY';
      case ActivityLevel.lightlyActive:
        return 'LIGHTLY_ACTIVE';
      case ActivityLevel.moderatelyActive:
        return 'MODERATELY_ACTIVE';
      case ActivityLevel.veryActive:
        return 'VERY_ACTIVE';
      case ActivityLevel.extremelyActive:
        return 'EXTREMELY_ACTIVE';
    }
  }
}
