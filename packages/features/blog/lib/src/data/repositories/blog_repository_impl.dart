import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/blog_category.dart';
import '../../domain/entities/blog_comment.dart';
import '../../domain/entities/blog_post.dart';
import '../../domain/repositories/blog_repository.dart';
import '../datasources/blog_local_datasource.dart';
import '../datasources/blog_remote_datasource.dart';

@LazySingleton(as: BlogRepository)
class BlogRepositoryImpl implements BlogRepository {

  const BlogRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final BlogRemoteDataSource remoteDataSource;
  final BlogLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<BlogPost>>> getBlogPosts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    BlogPostStatus? status,
    String? authorId,
  }) async {
    try {
      // Try to get data from remote
      try {
        final remotePosts = await remoteDataSource.getBlogPosts(
          page: page,
          limit: limit,
          category: category,
          search: search,
          status: status,
          authorId: authorId,
        );

        // Cache the posts locally
        await localDataSource.cacheBlogPosts(remotePosts);

        return Right(remotePosts.map((model) => model.toEntity()).toList());
      } catch (e) {
        // Fall back to cached data if remote fails
        final cachedPosts = await localDataSource.getCachedBlogPosts();
        return Right(cachedPosts.map((model) => model.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> getBlogPostById(String id) async {
    try {
      // Try cache first for better performance
      try {
        final cachedPost = await localDataSource.getCachedBlogPostById(id);
        if (cachedPost != null) {
          return Right(cachedPost.toEntity());
        }
      } catch (e) {
        // Continue to remote if cache fails
      }

      final remotePost = await remoteDataSource.getBlogPostById(id);
      await localDataSource.cacheBlogPost(remotePost);
      return Right(remotePost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> getBlogPostBySlug(String slug) async {
    try {
      final remotePost = await remoteDataSource.getBlogPostBySlug(slug);
      await localDataSource.cacheBlogPost(remotePost);
      return Right(remotePost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> createBlogPost(
    Map<String, dynamic> data,
  ) async {
    try {
      final createdPost = await remoteDataSource.createBlogPost(data);
      await localDataSource.cacheBlogPost(createdPost);
      return Right(createdPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> updateBlogPost(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedPost = await remoteDataSource.updateBlogPost(id, data);
      await localDataSource.cacheBlogPost(updatedPost);
      return Right(updatedPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBlogPost(String id) async {
    try {
      await remoteDataSource.deleteBlogPost(id);
      await localDataSource.removeCachedBlogPost(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> getFeaturedPosts() async {
    try {
      final featuredPosts = await remoteDataSource.getFeaturedPosts();
      return Right(featuredPosts.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> getRecentPosts({
    int limit = 10,
  }) async {
    try {
      final recentPosts = await remoteDataSource.getRecentPosts(limit: limit);
      return Right(recentPosts.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> getPopularPosts({
    int limit = 10,
  }) async {
    try {
      final popularPosts = await remoteDataSource.getPopularPosts(limit: limit);
      return Right(popularPosts.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  }) async {
    try {
      final relatedPosts = await remoteDataSource.getRelatedPosts(
        postId,
        limit: limit,
      );
      return Right(relatedPosts.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> likeBlogPost(String id) async {
    try {
      final likedPost = await remoteDataSource.likeBlogPost(id);
      await localDataSource.addLikedPost(id);
      await localDataSource.cacheBlogPost(likedPost);
      return Right(likedPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> unlikeBlogPost(String id) async {
    try {
      final unlikedPost = await remoteDataSource.unlikeBlogPost(id);
      await localDataSource.removeLikedPost(id);
      await localDataSource.cacheBlogPost(unlikedPost);
      return Right(unlikedPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> bookmarkBlogPost(String id) async {
    try {
      final bookmarkedPost = await remoteDataSource.bookmarkBlogPost(id);
      await localDataSource.addBookmark(id);
      await localDataSource.cacheBlogPost(bookmarkedPost);
      return Right(bookmarkedPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPost>> unbookmarkBlogPost(String id) async {
    try {
      final unbookmarkedPost = await remoteDataSource.unbookmarkBlogPost(id);
      await localDataSource.removeBookmark(id);
      await localDataSource.cacheBlogPost(unbookmarkedPost);
      return Right(unbookmarkedPost.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String id) async {
    try {
      await remoteDataSource.incrementViewCount(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogCategory>>> getBlogCategories() async {
    try {
      // Try cache first
      try {
        final cachedCategories = await localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return Right(
            cachedCategories.map((model) => model.toEntity()).toList(),
          );
        }
      } catch (e) {
        // Continue to remote if cache fails
      }

      final remoteCategories = await remoteDataSource.getBlogCategories();
      await localDataSource.cacheCategories(remoteCategories);
      return Right(remoteCategories.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogCategory>> getBlogCategoryById(String id) async {
    try {
      // Try cache first
      try {
        final cachedCategory = await localDataSource.getCachedCategoryById(id);
        if (cachedCategory != null) {
          return Right(cachedCategory.toEntity());
        }
      } catch (e) {
        // Continue to remote if cache fails
      }

      final remoteCategory = await remoteDataSource.getBlogCategoryById(id);
      await localDataSource.cacheCategory(remoteCategory);
      return Right(remoteCategory.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogCategory>> createBlogCategory(
    Map<String, dynamic> data,
  ) async {
    try {
      final createdCategory = await remoteDataSource.createBlogCategory(data);
      await localDataSource.cacheCategory(createdCategory);
      return Right(createdCategory.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogCategory>> updateBlogCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedCategory = await remoteDataSource.updateBlogCategory(
        id,
        data,
      );
      await localDataSource.cacheCategory(updatedCategory);
      return Right(updatedCategory.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBlogCategory(String id) async {
    try {
      await remoteDataSource.deleteBlogCategory(id);
      await localDataSource.removeCachedCategory(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogComment>>> getBlogComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Try cache first
      try {
        final cachedComments = await localDataSource.getCachedComments(postId);
        if (cachedComments.isNotEmpty) {
          return Right(
            cachedComments.map((model) => model.toEntity()).toList(),
          );
        }
      } catch (e) {
        // Continue to remote if cache fails
      }

      final remoteComments = await remoteDataSource.getBlogComments(
        postId,
        page: page,
        limit: limit,
      );
      await localDataSource.cacheComments(postId, remoteComments);
      return Right(remoteComments.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogComment>> createBlogComment(
    Map<String, dynamic> data,
  ) async {
    try {
      final createdComment = await remoteDataSource.createBlogComment(data);
      await localDataSource.cacheComment(createdComment);
      return Right(createdComment.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogComment>> updateBlogComment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final updatedComment = await remoteDataSource.updateBlogComment(id, data);
      await localDataSource.cacheComment(updatedComment);
      return Right(updatedComment.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBlogComment(String id) async {
    try {
      await remoteDataSource.deleteBlogComment(id);
      await localDataSource.removeCachedComment(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogComment>> likeBlogComment(String id) async {
    try {
      final likedComment = await remoteDataSource.likeBlogComment(id);
      await localDataSource.cacheComment(likedComment);
      return Right(likedComment.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogComment>> unlikeBlogComment(String id) async {
    try {
      final unlikedComment = await remoteDataSource.unlikeBlogComment(id);
      await localDataSource.cacheComment(unlikedComment);
      return Right(unlikedComment.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> searchBlogPosts(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
    List<String>? tags,
  }) async {
    try {
      // Save search query to history
      await localDataSource.addSearchQuery(query);

      final searchResults = await remoteDataSource.searchBlogPosts(
        query,
        page: page,
        limit: limit,
        category: category,
        tags: tags,
      );

      return Right(searchResults.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBlogTags({String? search}) async {
    try {
      final tags = await remoteDataSource.getBlogTags(search: search);
      return Right(tags);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPost>>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final bookmarkedPosts = await remoteDataSource.getBookmarkedPosts(
        page: page,
        limit: limit,
      );
      return Right(bookmarkedPosts.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<BlogPost> watchBlogPost(String id) {
    return localDataSource.watchBlogPost(id).map((model) => model.toEntity());
  }

  @override
  Stream<List<BlogComment>> watchBlogComments(String postId) {
    return localDataSource
        .watchBlogComments(postId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }
}
