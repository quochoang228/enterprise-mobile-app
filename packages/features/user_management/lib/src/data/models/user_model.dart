import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default(false) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _UserModel;
  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    isVerified: json['is_verified'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'avatar_url': avatarUrl,
    'is_verified': isVerified,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  User toEntity() => User(
    id: id,
    email: email,
    username: username,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    isVerified: isVerified,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    username: user.username,
    firstName: user.firstName,
    lastName: user.lastName,
    avatarUrl: user.avatarUrl,
    isVerified: user.isVerified,
    isActive: user.isActive,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  );
}
