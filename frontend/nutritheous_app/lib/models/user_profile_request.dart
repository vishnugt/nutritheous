import 'package:json_annotation/json_annotation.dart';
import 'activity_level.dart';
import 'sex.dart';

part 'user_profile_request.g.dart';

/// Request for updating user profile (matches UserProfileRequest from API)
@JsonSerializable()
class UserProfileRequest {
  final int? age;

  @JsonKey(name: 'heightCm')
  final double? heightCm;

  @JsonKey(name: 'weightKg')
  final double? weightKg;

  final Sex? sex;

  @JsonKey(name: 'activityLevel')
  final ActivityLevel? activityLevel;

  const UserProfileRequest({
    this.age,
    this.heightCm,
    this.weightKg,
    this.sex,
    this.activityLevel,
  });

  factory UserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UserProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileRequestToJson(this);
}
