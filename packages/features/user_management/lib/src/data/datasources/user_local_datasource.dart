import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserById(String id);
  Future<void> cacheUser(UserModel user);
  Future<void> removeUser(String id);
  Stream<UserModel> watchUser(String id);
}

@LazySingleton(as: UserLocalDataSource)
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final CacheManager _cacheManager;
  static const String _currentUserKey = 'current_user';
  static const String _userKeyPrefix = 'user_';

  UserLocalDataSourceImpl(this._cacheManager);

  @override
  Future<UserModel?> getCurrentUser() async {
    final userData = await _cacheManager.get<Map<String, dynamic>>(
      _currentUserKey,
    );
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final userData = await _cacheManager.get<Map<String, dynamic>>(
      '$_userKeyPrefix$id',
    );
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userData = user.toJson();
    await _cacheManager.set('$_userKeyPrefix${user.id}', userData);

    // Also cache as current user if it's the authenticated user
    // This would be determined by comparing with stored user ID
    await _cacheManager.set(_currentUserKey, userData);
  }

  @override
  Future<void> removeUser(String id) async {
    await _cacheManager.remove('$_userKeyPrefix$id');
  }

  @override
  Stream<UserModel> watchUser(String id) {
    // This is a simplified implementation
    // In a real app, you might use a more sophisticated approach like StreamController
    return Stream.periodic(const Duration(seconds: 1), (_) async {
          return await getUserById(id);
        })
        .asyncMap((future) => future)
        .where((user) => user != null)
        .cast<UserModel>();
  }
}
