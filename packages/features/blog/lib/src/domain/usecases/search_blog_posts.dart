import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/blog_post.dart';
import '../repositories/blog_repository.dart';

@injectable
class SearchBlogPosts {

  SearchBlogPosts(this._repository);
  final BlogRepository _repository;

  Future<Either<Failure, List<BlogPost>>> call(
    SearchBlogPostsParams params,
  ) async {
    if (params.query.trim().isEmpty) {
      return const Left( ValidationFailure('Search query cannot be empty'));
    }

    return _repository.searchBlogPosts(
      params.query,
      page: params.page,
      limit: params.limit,
      category: params.category,
      tags: params.tags,
    );
  }
}

class SearchBlogPostsParams {

  const SearchBlogPostsParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.category,
    this.tags,
  });
  final String query;
  final int page;
  final int limit;
  final String? category;
  final List<String>? tags;
}
