import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../domain/usecases/update_user.dart';

// Providers for use cases
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  throw UnimplementedError('GetCurrentUser provider not configured');
});

final getUserByIdProvider = Provider<GetUserById>((ref) {
  throw UnimplementedError('GetUserById provider not configured');
});

final updateUserProvider = Provider<UpdateUser>((ref) {
  throw UnimplementedError('UpdateUser provider not configured');
});

// Current user state provider
final userProvider = FutureProvider<User>((ref) async {
  final getCurrentUser = ref.read(getCurrentUserProvider);
  final result = await getCurrentUser();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// User by ID provider
final userByIdProvider = FutureProvider.family<User, String>((
  ref,
  userId,
) async {
  final getUserById = ref.read(getUserByIdProvider);
  final result = await getUserById(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// User update state provider
final userUpdateProvider =
    StateNotifierProvider<UserUpdateNotifier, AsyncValue<void>>((ref) {
      final updateUser = ref.read(updateUserProvider);
      return UserUpdateNotifier(updateUser);
    });

class UserUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final UpdateUser _updateUser;

  UserUpdateNotifier(this._updateUser) : super(const AsyncValue.data(null));
  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();

    // Convert User entity to update map
    final updates = {
      'email': user.email,
      'username': user.username,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'avatar_url': user.avatarUrl,
      'is_verified': user.isVerified,
      'is_active': user.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final result = await _updateUser(user.id, updates);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}
