import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class UpdateUser {
  final UserRepository _repository;

  UpdateUser(this._repository);

  Future<Either<Failure, User>> call(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return await _repository.updateUser(id, updates);
  }
}
