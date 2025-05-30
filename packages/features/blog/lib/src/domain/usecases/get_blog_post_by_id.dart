import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/blog_post.dart';
import '../repositories/blog_repository.dart';

@injectable
class GetBlogPostById {

  GetBlogPostById(this._repository);
  final BlogRepository _repository;

  Future<Either<Failure, BlogPost>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('Post ID cannot be empty'));
    }

    return _repository.getBlogPostById(id);
  }
}
