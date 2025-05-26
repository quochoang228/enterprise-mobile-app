import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class GetUserById {
  final UserRepository _repository;

  GetUserById(this._repository);

  Future<Either<Failure, User>> call(String id) async {
    return await _repository.getUserById(id);
  }
}
