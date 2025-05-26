import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> getUserById(String id);
  Future<UserModel> updateUser(String id, Map<String, dynamic> updates);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> searchUsers(String query);
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/user/me');
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/users/$id');
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/users/$id',
      data: updates,
    );
    return UserModel.fromJson(response);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _apiClient.delete('/users/$id');
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/search',
      queryParameters: {'q': query},
    );

    final users = response['data'] as List<dynamic>;
    return users
        .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
        .toList();
  }
}
