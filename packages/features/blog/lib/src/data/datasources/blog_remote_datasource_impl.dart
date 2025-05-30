import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/blog_post.dart';
import '../models/blog_category_model.dart';
import '../models/blog_comment_model.dart';
import '../models/blog_post_model.dart';
import 'blog_remote_datasource.dart';

@LazySingleton(as: BlogRemoteDataSource)
class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {

  BlogRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<BlogPostModel>> getBlogPosts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    BlogPostStatus? status,
    String? authorId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (status != null) 'status': status.name,
        if (authorId != null) 'author_id': authorId,
      };

      final response = await _apiClient.get(
        '/blog/posts',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch blog posts: $e');
    }
  }

  @override
  Future<BlogPostModel> getBlogPostById(String id) async {
    try {
      final response = await _apiClient.get('/blog/posts/$id');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to fetch blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> getBlogPostBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/blog/posts/slug/$slug');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to fetch blog post by slug: $e');
    }
  }

  @override
  Future<BlogPostModel> createBlogPost(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/blog/posts', data: data);
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to create blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> updateBlogPost(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put('/blog/posts/$id', data: data);
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to update blog post: $e');
    }
  }

  @override
  Future<void> deleteBlogPost(String id) async {
    try {
      await _apiClient.delete('/blog/posts/$id');
    } catch (e) {
      throw NetworkException('Failed to delete blog post: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getFeaturedPosts() async {
    try {
      final response = await _apiClient.get('/blog/posts/featured');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch featured posts: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getRecentPosts({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/blog/posts/recent',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch recent posts: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getPopularPosts({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/blog/posts/popular',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch popular posts: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getRelatedPosts(
    String postId, {
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '/blog/posts/$postId/related',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch related posts: $e');
    }
  }

  @override
  Future<BlogPostModel> likeBlogPost(String id) async {
    try {
      final response = await _apiClient.post('/blog/posts/$id/like');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to like blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> unlikeBlogPost(String id) async {
    try {
      final response = await _apiClient.delete('/blog/posts/$id/like');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to unlike blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> bookmarkBlogPost(String id) async {
    try {
      final response = await _apiClient.post('/blog/posts/$id/bookmark');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to bookmark blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> unbookmarkBlogPost(String id) async {
    try {
      final response = await _apiClient.delete('/blog/posts/$id/bookmark');
      return BlogPostModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to unbookmark blog post: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await _apiClient.post('/blog/posts/$id/view');
    } catch (e) {
      throw NetworkException('Failed to increment view count: $e');
    }
  }

  @override
  Future<List<BlogCategoryModel>> getBlogCategories() async {
    try {
      final response = await _apiClient.get('/blog/categories');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogCategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch blog categories: $e');
    }
  }

  @override
  Future<BlogCategoryModel> getBlogCategoryById(String id) async {
    try {
      final response = await _apiClient.get('/blog/categories/$id');
      return BlogCategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to fetch blog category: $e');
    }
  }

  @override
  Future<BlogCategoryModel> createBlogCategory(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post('/blog/categories', data: data);
      return BlogCategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to create blog category: $e');
    }
  }

  @override
  Future<BlogCategoryModel> updateBlogCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put('/blog/categories/$id', data: data);
      return BlogCategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to update blog category: $e');
    }
  }

  @override
  Future<void> deleteBlogCategory(String id) async {
    try {
      await _apiClient.delete('/blog/categories/$id');
    } catch (e) {
      throw NetworkException('Failed to delete blog category: $e');
    }
  }

  @override
  Future<List<BlogCommentModel>> getBlogComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/blog/posts/$postId/comments',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogCommentModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch blog comments: $e');
    }
  }

  @override
  Future<BlogCommentModel> createBlogComment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/blog/comments', data: data);
      return BlogCommentModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to create blog comment: $e');
    }
  }

  @override
  Future<BlogCommentModel> updateBlogComment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put('/blog/comments/$id', data: data);
      return BlogCommentModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to update blog comment: $e');
    }
  }

  @override
  Future<void> deleteBlogComment(String id) async {
    try {
      await _apiClient.delete('/blog/comments/$id');
    } catch (e) {
      throw NetworkException('Failed to delete blog comment: $e');
    }
  }

  @override
  Future<BlogCommentModel> likeBlogComment(String id) async {
    try {
      final response = await _apiClient.post('/blog/comments/$id/like');
      return BlogCommentModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to like blog comment: $e');
    }
  }

  @override
  Future<BlogCommentModel> unlikeBlogComment(String id) async {
    try {
      final response = await _apiClient.delete('/blog/comments/$id/like');
      return BlogCommentModel.fromJson(response.data['data']);
    } catch (e) {
      throw NetworkException('Failed to unlike blog comment: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> searchBlogPosts(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
      };

      final response = await _apiClient.get(
        '/blog/search',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to search blog posts: $e');
    }
  }

  @override
  Future<List<String>> getBlogTags({String? search}) async {
    try {
      final queryParams = <String, dynamic>{
        if (search != null) 'search': search,
      };

      final response = await _apiClient.get(
        '/blog/tags',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<String>();
    } catch (e) {
      throw NetworkException('Failed to fetch blog tags: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/blog/bookmarks',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BlogPostModel.fromJson(json)).toList();
    } catch (e) {
      throw NetworkException('Failed to fetch bookmarked posts: $e');
    }
  }
}
