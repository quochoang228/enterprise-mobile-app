import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class GetCurrentUser {

  GetCurrentUser(this._repository);
  final UserRepository _repository;

  Future<Either<Failure, User>> call() async => _repository.getCurrentUser();
}
