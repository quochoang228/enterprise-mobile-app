import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../models/blog_post_model.dart';
import '../models/blog_category_model.dart';
import '../models/blog_comment_model.dart';
import 'blog_local_datasource.dart';

@LazySingleton(as: BlogLocalDataSource)
class BlogLocalDataSourceImpl implements BlogLocalDataSource {

  BlogLocalDataSourceImpl(this._cacheManager, this._storageService);
  final CacheManager _cacheManager;
  final StorageService _storageService;

  // Stream controllers for real-time updates
  final _blogPostStreamController = StreamController<BlogPostModel>.broadcast();
  final _commentsStreamController =
      StreamController<List<BlogCommentModel>>.broadcast();

  // Cache keys
  static const String _blogPostsKey = 'blog_posts';
  static const String _categoriesKey = 'blog_categories';
  static const String _commentsKey = 'blog_comments';
  static const String _bookmarksKey = 'blog_bookmarks';
  static const String _likedPostsKey = 'blog_liked_posts';
  static const String _searchHistoryKey = 'blog_search_history';

  @override
  Future<List<BlogPostModel>> getCachedBlogPosts() async {
    try {
      final cachedData = await _cacheManager.get<String>(_blogPostsKey);
      if (cachedData == null) return [];

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached blog posts: $e');
    }
  }

  @override
  Future<BlogPostModel?> getCachedBlogPostById(String id) async {
    try {
      final cachedPosts = await getCachedBlogPosts();
      return cachedPosts.where((post) => post.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheBlogPost(BlogPostModel post) async {
    try {
      final cachedPosts = await getCachedBlogPosts();

      // Remove existing post with same ID
      cachedPosts.removeWhere((p) => p.id == post.id);

      // Add new post at the beginning
      cachedPosts.insert(0, post);

      // Keep only latest 100 posts
      if (cachedPosts.length > 100) {
        cachedPosts.removeRange(100, cachedPosts.length);
      }

      await _cachePosts(cachedPosts);

      // Emit update to stream
      _blogPostStreamController.add(post);
    } catch (e) {
      throw CacheException('Failed to cache blog post: $e');
    }
  }

  @override
  Future<void> cacheBlogPosts(List<BlogPostModel> posts) async {
    try {
      await _cachePosts(posts);
    } catch (e) {
      throw CacheException('Failed to cache blog posts: $e');
    }
  }

  Future<void> _cachePosts(List<BlogPostModel> posts) async {
    final jsonString = jsonEncode(posts.map((post) => post.toJson()).toList());
    await _cacheManager.set(
      _blogPostsKey,
      jsonString,
      ttl: const Duration(hours: 1),
    );
  }

  @override
  Future<void> removeCachedBlogPost(String id) async {
    try {
      final cachedPosts = await getCachedBlogPosts();
      cachedPosts.removeWhere((post) => post.id == id);
      await _cachePosts(cachedPosts);
    } catch (e) {
      throw CacheException('Failed to remove cached blog post: $e');
    }
  }

  @override
  Future<void> clearBlogPostsCache() async {
    try {
      await _cacheManager.remove(_blogPostsKey);
    } catch (e) {
      throw CacheException('Failed to clear blog posts cache: $e');
    }
  }

  @override
  Future<List<BlogCategoryModel>> getCachedCategories() async {
    try {
      final cachedData = await _cacheManager.get<String>(_categoriesKey);
      if (cachedData == null) return [];

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((json) => BlogCategoryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BlogCategoryModel?> getCachedCategoryById(String id) async {
    try {
      final cachedCategories = await getCachedCategories();
      return cachedCategories
          .where((category) => category.id == id)
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCategory(BlogCategoryModel category) async {
    try {
      final cachedCategories = await getCachedCategories();
      cachedCategories..removeWhere((c) => c.id == category.id)
      ..add(category);
      await cacheCategories(cachedCategories);
    } catch (e) {
      throw CacheException('Failed to cache category: $e');
    }
  }

  @override
  Future<void> cacheCategories(List<BlogCategoryModel> categories) async {
    try {
      final jsonString = jsonEncode(
        categories.map((cat) => cat.toJson()).toList(),
      );
      await _cacheManager.set(
        _categoriesKey,
        jsonString,
        ttl: const Duration(hours: 6),
      );
    } catch (e) {
      throw CacheException('Failed to cache categories: $e');
    }
  }

  @override
  Future<void> removeCachedCategory(String id) async {
    try {
      final cachedCategories = await getCachedCategories();
      cachedCategories.removeWhere((category) => category.id == id);
      await cacheCategories(cachedCategories);
    } catch (e) {
      throw CacheException('Failed to remove cached category: $e');
    }
  }

  @override
  Future<void> clearCategoriesCache() async {
    try {
      await _cacheManager.remove(_categoriesKey);
    } catch (e) {
      throw CacheException('Failed to clear categories cache: $e');
    }
  }

  @override
  Future<List<BlogCommentModel>> getCachedComments(String postId) async {
    try {
      final cachedData = await _cacheManager.get<String>(
        '${_commentsKey}_$postId',
      );
      if (cachedData == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((json) => BlogCommentModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BlogCommentModel?> getCachedCommentById(String id) async {
    try {
      // This would require searching through all cached comments
      // For now, return null - implement if needed
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheComment(BlogCommentModel comment) async {
    try {
      final cachedComments = await getCachedComments(comment.postId);
      cachedComments..removeWhere((c) => c.id == comment.id)
      ..add(comment);
      await cacheComments(comment.postId, cachedComments);
    } catch (e) {
      throw CacheException('Failed to cache comment: $e');
    }
  }

  @override
  Future<void> cacheComments(
    String postId,
    List<BlogCommentModel> comments,
  ) async {
    try {
      final jsonString = jsonEncode(
        comments.map((comment) => comment.toJson()).toList(),
      );
      await _cacheManager.set(
        '${_commentsKey}_$postId',
        jsonString,
        ttl: const Duration(minutes: 30),
      );

      // Emit update to stream
      _commentsStreamController.add(comments);
    } catch (e) {
      throw CacheException('Failed to cache comments: $e');
    }
  }

  @override
  Future<void> removeCachedComment(String id) async {
    try {
      // This would require searching through all cached comments
      // For now, do nothing - implement if needed
    } catch (e) {
      throw CacheException('Failed to remove cached comment: $e');
    }
  }

  @override
  Future<void> clearCommentsCache() async {
    try {
      // Remove all comment cache keys
      // This is a simplified implementation
      await _cacheManager.clear();
    } catch (e) {
      throw CacheException('Failed to clear comments cache: $e');
    }
  }

  @override
  Future<List<String>> getBookmarkedPostIds() async {
    try {
      final bookmarks = await _storageService.getStringList(_bookmarksKey);
      return bookmarks ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isPostBookmarked(String postId) async {
    try {
      final bookmarks = await getBookmarkedPostIds();
      return bookmarks.contains(postId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> addBookmark(String postId) async {
    try {
      final bookmarks = await getBookmarkedPostIds();
      if (!bookmarks.contains(postId)) {
        bookmarks.add(postId);
        await _storageService.setStringList(_bookmarksKey, bookmarks);
      }
    } catch (e) {
      throw CacheException('Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> removeBookmark(String postId) async {
    try {
      final bookmarks = await getBookmarkedPostIds();
      bookmarks.remove(postId);
      await _storageService.setStringList(_bookmarksKey, bookmarks);
    } catch (e) {
      throw CacheException('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<void> clearBookmarks() async {
    try {
      await _storageService.remove(_bookmarksKey);
    } catch (e) {
      throw CacheException('Failed to clear bookmarks: $e');
    }
  }

  @override
  Future<List<String>> getLikedPostIds() async {
    try {
      final likedPosts = await _storageService.getStringList(_likedPostsKey);
      return likedPosts ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isPostLiked(String postId) async {
    try {
      final likedPosts = await getLikedPostIds();
      return likedPosts.contains(postId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> addLikedPost(String postId) async {
    try {
      final likedPosts = await getLikedPostIds();
      if (!likedPosts.contains(postId)) {
        likedPosts.add(postId);
        await _storageService.setStringList(_likedPostsKey, likedPosts);
      }
    } catch (e) {
      throw CacheException('Failed to add liked post: $e');
    }
  }

  @override
  Future<void> removeLikedPost(String postId) async {
    try {
      final likedPosts = await getLikedPostIds();
      likedPosts.remove(postId);
      await _storageService.setStringList(_likedPostsKey, likedPosts);
    } catch (e) {
      throw CacheException('Failed to remove liked post: $e');
    }
  }

  @override
  Future<void> clearLikedPosts() async {
    try {
      await _storageService.remove(_likedPostsKey);
    } catch (e) {
      throw CacheException('Failed to clear liked posts: $e');
    }
  }

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      final searchHistory = await _storageService.getStringList(
        _searchHistoryKey,
      );
      return searchHistory ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addSearchQuery(String query) async {
    try {
      final searchHistory = await getSearchHistory();

      // Remove if already exists
      searchHistory..remove(query)

      // Add to beginning
      ..insert(0, query);

      // Keep only latest 20 searches
      if (searchHistory.length > 20) {
        searchHistory.removeRange(20, searchHistory.length);
      }

      await _storageService.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      throw CacheException('Failed to add search query: $e');
    }
  }

  @override
  Future<void> removeSearchQuery(String query) async {
    try {
      final searchHistory = await getSearchHistory();
      searchHistory.remove(query);
      await _storageService.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      throw CacheException('Failed to remove search query: $e');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await _storageService.remove(_searchHistoryKey);
    } catch (e) {
      throw CacheException('Failed to clear search history: $e');
    }
  }

  @override
  Stream<BlogPostModel> watchBlogPost(String id) => _blogPostStreamController.stream.where((post) => post.id == id);

  @override
  Stream<List<BlogCommentModel>> watchBlogComments(String postId) => _commentsStreamController.stream;

  void dispose() {
    _blogPostStreamController.close();
    _commentsStreamController.close();
  }
}
