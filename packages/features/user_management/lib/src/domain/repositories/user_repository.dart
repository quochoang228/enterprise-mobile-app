import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, User>> updateUser(
    String id,
    Map<String, dynamic> updates,
  );
  Future<Either<Failure, void>> deleteUser(String id);
  Future<Either<Failure, List<User>>> searchUsers(String query);
  Stream<User> watchUser(String id);
}
