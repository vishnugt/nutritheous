import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

/// Represents an authenticated user (matches AuthResponse from API)
@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: 'userId')
  final String userId;

  final String email;

  final String? token;

  final String? role;

  const User({
    required this.userId,
    required this.email,
    this.token,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [userId, email, token, role];

  User copyWith({
    String? userId,
    String? email,
    String? token,
    String? role,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }

  /// Get the user ID (alias for userId for backward compatibility)
  String get id => userId;

  /// Get the JWT token (alias for token for backward compatibility)
  String? get jwtToken => token;
}
