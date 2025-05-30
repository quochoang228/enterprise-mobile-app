import '../models/blog_post_model.dart';
import '../models/blog_category_model.dart';
import '../models/blog_comment_model.dart';

abstract class BlogLocalDataSource {
  // Blog Posts Cache
  Future<List<BlogPostModel>> getCachedBlogPosts();
  Future<BlogPostModel?> getCachedBlogPostById(String id);
  Future<void> cacheBlogPost(BlogPostModel post);
  Future<void> cacheBlogPosts(List<BlogPostModel> posts);
  Future<void> removeCachedBlogPost(String id);
  Future<void> clearBlogPostsCache();

  // Categories Cache
  Future<List<BlogCategoryModel>> getCachedCategories();
  Future<BlogCategoryModel?> getCachedCategoryById(String id);
  Future<void> cacheCategory(BlogCategoryModel category);
  Future<void> cacheCategories(List<BlogCategoryModel> categories);
  Future<void> removeCachedCategory(String id);
  Future<void> clearCategoriesCache();

  // Comments Cache
  Future<List<BlogCommentModel>> getCachedComments(String postId);
  Future<BlogCommentModel?> getCachedCommentById(String id);
  Future<void> cacheComment(BlogCommentModel comment);
  Future<void> cacheComments(String postId, List<BlogCommentModel> comments);
  Future<void> removeCachedComment(String id);
  Future<void> clearCommentsCache();

  // Bookmarks
  Future<List<String>> getBookmarkedPostIds();
  Future<bool> isPostBookmarked(String postId);
  Future<void> addBookmark(String postId);
  Future<void> removeBookmark(String postId);
  Future<void> clearBookmarks();

  // Liked Posts
  Future<List<String>> getLikedPostIds();
  Future<bool> isPostLiked(String postId);
  Future<void> addLikedPost(String postId);
  Future<void> removeLikedPost(String postId);
  Future<void> clearLikedPosts();

  // Search History
  Future<List<String>> getSearchHistory();
  Future<void> addSearchQuery(String query);
  Future<void> removeSearchQuery(String query);
  Future<void> clearSearchHistory();

  // Streams for real-time updates
  Stream<BlogPostModel> watchBlogPost(String id);
  Stream<List<BlogCommentModel>> watchBlogComments(String postId);
}
