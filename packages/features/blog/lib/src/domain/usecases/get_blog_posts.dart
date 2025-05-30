import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/blog_post.dart';
import '../repositories/blog_repository.dart';


@injectable
class GetBlogPosts {

  GetBlogPosts(this._repository);
  final BlogRepository _repository;

  Future<Either<Failure, List<BlogPost>>> call(
    GetBlogPostsParams params,
  ) async => _repository.getBlogPosts(
      page: params.page,
      limit: params.limit,
      category: params.category,
      search: params.search,
      status: params.status,
      authorId: params.authorId,
    );
}

class GetBlogPostsParams {

  const GetBlogPostsParams({
    this.page = 1,
    this.limit = 20,
    this.category,
    this.search,
    this.status,
    this.authorId,
  });
  final int page;
  final int limit;
  final String? category;
  final String? search;
  final BlogPostStatus? status;
  final String? authorId;
}
