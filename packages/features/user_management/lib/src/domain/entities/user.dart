import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
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
  }) = _User;

  const User._();

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return username.substring(0, 2).toUpperCase();
  }

  String get fullName => displayName;
}
