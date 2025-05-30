import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/blog_comment.dart';
import '../repositories/blog_repository.dart';

@injectable
class GetBlogComments {

  GetBlogComments(this._repository);
  final BlogRepository _repository;

  Future<Either<Failure, List<BlogComment>>> call(
    GetBlogCommentsParams params,
  ) async {
    if (params.postId.isEmpty) {
      return const Left(ValidationFailure('Post ID cannot be empty'));
    }

    return _repository.getBlogComments(
      params.postId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetBlogCommentsParams {

  const GetBlogCommentsParams({
    required this.postId,
    this.page = 1,
    this.limit = 20,
  });
  final String postId;
  final int page;
  final int limit;
}
