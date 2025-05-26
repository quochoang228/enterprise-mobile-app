import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class GetCurrentUser {
  final UserRepository _repository;

  GetCurrentUser(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.getCurrentUser();
  }
}
