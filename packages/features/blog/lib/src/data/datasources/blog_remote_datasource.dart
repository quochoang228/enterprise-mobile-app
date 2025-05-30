import '../../domain/entities/blog_post.dart';
import '../models/blog_category_model.dart';
import '../models/blog_comment_model.dart';
import '../models/blog_post_model.dart';

abstract class BlogRemoteDataSource {
  // Blog Posts
  Future<List<BlogPostModel>> getBlogPosts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    BlogPostStatus? status,
    String? authorId,
  });

  Future<BlogPostModel> getBlogPostById(String id);
  Future<BlogPostModel> getBlogPostBySlug(String slug);

  Future<BlogPostModel> createBlogPost(Map<String, dynamic> data);
  Future<BlogPostModel> updateBlogPost(String id, Map<String, dynamic> data);
  Future<void> deleteBlogPost(String id);

  Future<List<BlogPostModel>> getFeaturedPosts();
  Future<List<BlogPostModel>> getRecentPosts({int limit = 10});
  Future<List<BlogPostModel>> getPopularPosts({int limit = 10});
  Future<List<BlogPostModel>> getRelatedPosts(String postId, {int limit = 5});

  // Interactions
  Future<BlogPostModel> likeBlogPost(String id);
  Future<BlogPostModel> unlikeBlogPost(String id);
  Future<BlogPostModel> bookmarkBlogPost(String id);
  Future<BlogPostModel> unbookmarkBlogPost(String id);
  Future<void> incrementViewCount(String id);

  // Categories
  Future<List<BlogCategoryModel>> getBlogCategories();
  Future<BlogCategoryModel> getBlogCategoryById(String id);
  Future<BlogCategoryModel> createBlogCategory(Map<String, dynamic> data);
  Future<BlogCategoryModel> updateBlogCategory(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteBlogCategory(String id);

  // Comments
  Future<List<BlogCommentModel>> getBlogComments(
    String postId, {
    int page = 1,
    int limit = 20,
  });
  Future<BlogCommentModel> createBlogComment(Map<String, dynamic> data);
  Future<BlogCommentModel> updateBlogComment(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteBlogComment(String id);
  Future<BlogCommentModel> likeBlogComment(String id);
  Future<BlogCommentModel> unlikeBlogComment(String id);

  // Search & Filter
  Future<List<BlogPostModel>> searchBlogPosts(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
    List<String>? tags,
  });

  Future<List<String>> getBlogTags({String? search});

  // Bookmarks
  Future<List<BlogPostModel>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  });
}
