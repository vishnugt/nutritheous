import 'package:json_annotation/json_annotation.dart';

/// Sex for calorie calculation
/// OTHER uses average of male and female BMR calculations
enum Sex {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
  @JsonValue('OTHER')
  other,
}

extension SexExtension on Sex {
  String get displayName {
    switch (this) {
      case Sex.male:
        return 'Male';
      case Sex.female:
        return 'Female';
      case Sex.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case Sex.male:
        return 'MALE';
      case Sex.female:
        return 'FEMALE';
      case Sex.other:
        return 'OTHER';
    }
  }
}
