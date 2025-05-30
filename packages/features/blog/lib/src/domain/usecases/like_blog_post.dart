import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/blog_post.dart';
import '../repositories/blog_repository.dart';

@injectable
class LikeBlogPost {

  LikeBlogPost(this._repository);
  final BlogRepository _repository;

  Future<Either<Failure, BlogPost>> call(String postId) async {
    if (postId.isEmpty) {
      return const Left( ValidationFailure('Post ID cannot be empty'));
    }

    return _repository.likeBlogPost(postId);
  }
}
