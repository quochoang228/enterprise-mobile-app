import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../user_management.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from local first
      final localUser = await _localDataSource.getCurrentUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Fallback to remote
      final remoteUser = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      // Try local first
      final localUser = await _localDataSource.getUserById(id);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Fallback to remote
      final remoteUser = await _remoteDataSource.getUserById(id);
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final updatedUser = await _remoteDataSource.updateUser(id, updates);
      await _localDataSource.cacheUser(updatedUser);
      return Right(updatedUser.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      await _localDataSource.removeUser(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await _remoteDataSource.searchUsers(query);
      return Right(users.map((user) => user.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<User> watchUser(String id) {
    return _localDataSource
        .watchUser(id)
        .map((userModel) => userModel.toEntity());
  }
}
