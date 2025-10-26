import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'activity_level.dart';
import 'sex.dart';

part 'user_profile.g.dart';

/// User profile with biometric and activity data (matches UserProfileResponse from API)
@JsonSerializable()
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? role;

  // Profile fields
  final int? age;

  @JsonKey(name: 'heightCm')
  final double? heightCm;

  @JsonKey(name: 'weightKg')
  final double? weightKg;

  final Sex? sex;

  @JsonKey(name: 'activityLevel')
  final ActivityLevel? activityLevel;

  // Calculated field
  @JsonKey(name: 'estimatedCaloriesBurntPerDay')
  final int? estimatedCaloriesBurntPerDay;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.role,
    this.age,
    this.heightCm,
    this.weightKg,
    this.sex,
    this.activityLevel,
    this.estimatedCaloriesBurntPerDay,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        age,
        heightCm,
        weightKg,
        sex,
        activityLevel,
        estimatedCaloriesBurntPerDay,
        createdAt,
      ];

  UserProfile copyWith({
    String? id,
    String? email,
    String? role,
    int? age,
    double? heightCm,
    double? weightKg,
    Sex? sex,
    ActivityLevel? activityLevel,
    int? estimatedCaloriesBurntPerDay,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      estimatedCaloriesBurntPerDay:
          estimatedCaloriesBurntPerDay ?? this.estimatedCaloriesBurntPerDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if profile is complete for calorie calculation
  bool get isProfileComplete =>
      age != null &&
      heightCm != null &&
      weightKg != null &&
      sex != null &&
      activityLevel != null;
}
