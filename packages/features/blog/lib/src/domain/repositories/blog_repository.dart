import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/blog_category.dart';
import '../entities/blog_comment.dart';
import '../entities/blog_post.dart';

abstract class BlogRepository {
  // Blog Posts
  Future<Either<Failure, List<BlogPost>>> getBlogPosts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    BlogPostStatus? status,
    String? authorId,
  });

  Future<Either<Failure, BlogPost>> getBlogPostById(String id);
  Future<Either<Failure, BlogPost>> getBlogPostBySlug(String slug);

  Future<Either<Failure, BlogPost>> createBlogPost(Map<String, dynamic> data);
  Future<Either<Failure, BlogPost>> updateBlogPost(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBlogPost(String id);

  Future<Either<Failure, List<BlogPost>>> getFeaturedPosts();
  Future<Either<Failure, List<BlogPost>>> getRecentPosts({int limit = 10});
  Future<Either<Failure, List<BlogPost>>> getPopularPosts({int limit = 10});
  Future<Either<Failure, List<BlogPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  });

  // Interactions
  Future<Either<Failure, BlogPost>> likeBlogPost(String id);
  Future<Either<Failure, BlogPost>> unlikeBlogPost(String id);
  Future<Either<Failure, BlogPost>> bookmarkBlogPost(String id);
  Future<Either<Failure, BlogPost>> unbookmarkBlogPost(String id);
  Future<Either<Failure, void>> incrementViewCount(String id);

  // Categories
  Future<Either<Failure, List<BlogCategory>>> getBlogCategories();
  Future<Either<Failure, BlogCategory>> getBlogCategoryById(String id);
  Future<Either<Failure, BlogCategory>> createBlogCategory(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, BlogCategory>> updateBlogCategory(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBlogCategory(String id);

  // Comments
  Future<Either<Failure, List<BlogComment>>> getBlogComments(
    String postId, {
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, BlogComment>> createBlogComment(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, BlogComment>> updateBlogComment(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBlogComment(String id);
  Future<Either<Failure, BlogComment>> likeBlogComment(String id);
  Future<Either<Failure, BlogComment>> unlikeBlogComment(String id);

  // Search & Filter
  Future<Either<Failure, List<BlogPost>>> searchBlogPosts(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
    List<String>? tags,
  });

  Future<Either<Failure, List<String>>> getBlogTags({String? search});

  // Bookmarks
  Future<Either<Failure, List<BlogPost>>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  });

  // Streams for real-time updates
  Stream<BlogPost> watchBlogPost(String id);
  Stream<List<BlogComment>> watchBlogComments(String postId);
}
