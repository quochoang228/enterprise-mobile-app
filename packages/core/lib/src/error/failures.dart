import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {int? code})
    : super(message, code: code);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {int? code}) : super(message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {int? code}) : super(message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {int? code})
    : super(message, code: code);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {int? code})
    : super(message, code: code);
}
