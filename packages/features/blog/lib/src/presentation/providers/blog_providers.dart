import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../domain/entities/blog_post.dart';
import '../../domain/entities/blog_category.dart';
import '../../domain/entities/blog_comment.dart';
import '../../domain/repositories/blog_repository.dart';
import '../../domain/usecases/get_blog_posts.dart';
import '../../domain/usecases/get_blog_post_by_id.dart';
import '../../domain/usecases/like_blog_post.dart';
import '../../domain/usecases/get_blog_comments.dart';
import '../../domain/usecases/search_blog_posts.dart';
import '../../data/repositories/blog_repository_impl.dart';
import '../../data/datasources/blog_remote_datasource.dart';
import '../../data/datasources/blog_remote_datasource_impl.dart';
import '../../data/datasources/blog_local_datasource.dart';
import '../../data/datasources/blog_local_datasource_impl.dart';

part 'blog_providers.g.dart';

// 🎯 Core Dependency Providers
@riverpod
ApiClient apiClient(ref) => ApiClient(baseUrl: 'https://api.example.com');

@riverpod
StorageService storageService(ref) => StorageService();

@riverpod
CacheManager mockCacheManager(ref) {
  // Create a mock cache manager for testing
  // In a real app, this would be provided by the app-level DI container
  throw UnimplementedError(
    'Mock CacheManager - requires Hive Box initialization',
  );
}

// 🎯 Data Source Providers
@riverpod
BlogRemoteDataSource blogRemoteDataSource(ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BlogRemoteDataSourceImpl(apiClient);
}

@riverpod
BlogLocalDataSource blogLocalDataSource(ref) {
  final storageService = ref.watch(storageServiceProvider);
  // Create a minimal mock cache manager
  final mockCache = _MockCacheManager();
  return BlogLocalDataSourceImpl(mockCache, storageService);
}

// Mock implementation for CacheManager to avoid Hive dependency
class _MockCacheManager extends CacheManager {
  _MockCacheManager() : super(null as dynamic);

  @override
  Future<T?> get<T>(String key, {Duration? ttl}) async => null;

  @override
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {}

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> init() async {}
}

// 🎯 Repository Provider
@riverpod
BlogRepository blogRepository(BlogRepositoryRef ref) {
  final remoteDataSource = ref.watch(blogRemoteDataSourceProvider);
  final localDataSource = ref.watch(blogLocalDataSourceProvider);

  return BlogRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}

// 🎯 Use Case Providers
@riverpod
GetBlogPosts getBlogPosts(GetBlogPostsRef ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return GetBlogPosts(repository);
}

@riverpod
GetBlogPostById getBlogPostById(GetBlogPostByIdRef ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return GetBlogPostById(repository);
}

// @riverpod
// LikeBlogPost likeBlogPost(Ref ref) {
//   final repository = ref.watch(blogRepositoryProvider);
//   return LikeBlogPost(repository);
// }

@riverpod
GetBlogComments getBlogComments(Ref ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return GetBlogComments(repository);
}

@riverpod
SearchBlogPosts searchBlogPosts(Ref ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return SearchBlogPosts(repository);
}

// 🎯 Main Blog Posts Provider (Mock Implementation)
@riverpod
Future<List<BlogPost>> blogPosts(Ref ref) async {
  try {
    final getBlogPostsUseCase = ref.watch(getBlogPostsProvider);
    const params = GetBlogPostsParams();
    final result = await getBlogPostsUseCase(params);

    return result.fold((failure) => throw failure, (posts) => posts);
  } catch (e) {
    // Fallback to mock data for demo
    debugPrint('BlogPosts use case not available, using mock data: $e');
    return _generateMockBlogPosts();
  }
}

// 🎯 Blog Post by ID Provider (Mock Implementation)
@riverpod
Future<BlogPost?> blogPost(Ref ref, String postId) async {
  try {
    final getBlogPostByIdUseCase = ref.watch(getBlogPostByIdProvider);
    final result = await getBlogPostByIdUseCase(postId);

    return result.fold((failure) {
      debugPrint('Error getting blog post: ${failure.message}');
      return null;
    }, (post) => post);
  } catch (e) {
    // Fallback to mock data
    debugPrint('GetBlogPostById not available, using mock data: $e');
    return _generateMockBlogPost(postId);
  }
}

// 🎯 Featured Posts Provider
@riverpod
Future<List<BlogPost>> featuredBlogPosts(Ref ref) async {
  try {
    // Try to get from repository when available
    final repository = ref.watch(blogRepositoryProvider);
    final result = await repository.getFeaturedPosts();

    return result.fold((failure) => throw failure, (posts) => posts);
  } catch (e) {
    // Fallback to mock featured posts
    debugPrint('Featured posts not available, using mock data: $e');
    final allPosts = _generateMockBlogPosts();
    return allPosts.take(3).toList();
  }
}

// 🎯 Recent Posts Provider
@riverpod
Future<List<BlogPost>> recentBlogPosts(Ref ref) async {
  try {
    final repository = ref.watch(blogRepositoryProvider);
    final result = await repository.getRecentPosts(limit: 5);

    return result.fold((failure) => throw failure, (posts) => posts);
  } catch (e) {
    // Fallback to mock recent posts
    debugPrint('Recent posts not available, using mock data: $e');
    final allPosts = _generateMockBlogPosts();
    return allPosts.take(5).toList();
  }
}

// 🎯 Blog Categories Provider
@riverpod
Future<List<BlogCategory>> blogCategories(Ref ref) async {
  try {
    final repository = ref.watch(blogRepositoryProvider);
    final result = await repository.getBlogCategories();

    return result.fold((failure) => throw failure, (categories) => categories);
  } catch (e) {
    // Fallback to mock categories
    debugPrint('Blog categories not available, using mock data: $e');
    return _generateMockCategories();
  }
}

// 🎯 Blog Comments Provider
@riverpod
Future<List<BlogComment>> blogComments(
  Ref ref,
  String postId,
) async {
  try {
    final getBlogCommentsUseCase = ref.watch(getBlogCommentsProvider);
    final params = GetBlogCommentsParams(postId: postId);
    final result = await getBlogCommentsUseCase(params);

    return result.fold((failure) => throw failure, (comments) => comments);
  } catch (e) {
    // Fallback to mock comments
    debugPrint('Blog comments not available, using mock data: $e');
    return _generateMockComments(postId);
  }
}

// 🔍 Search Providers
@riverpod
class BlogSearchNotifier extends _$BlogSearchNotifier {
  @override
  AsyncValue<List<BlogPost>> build() => const AsyncValue.data([]);

  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final searchBlogPostsUseCase = ref.read(searchBlogPostsProvider);
      final params = SearchBlogPostsParams(query: query);
      final result = await searchBlogPostsUseCase(params);

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (posts) => AsyncValue.data(posts),
      );
    } catch (e) {
      // Fallback to mock search
      debugPrint('Search not available, using mock search: $e');
      await Future.delayed(const Duration(milliseconds: 500));

      final mockResults = _generateMockSearchResults(query);
      state = AsyncValue.data(mockResults);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// 🎯 Search Query State
@riverpod
class BlogSearchQueryNotifier extends _$BlogSearchQueryNotifier {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// 🎯 Selected Category State
@riverpod
class SelectedCategoryNotifier extends _$SelectedCategoryNotifier {
  @override
  String? build() => null;

  void selectCategory(String? categoryId) {
    state = categoryId;
  }

  void clearCategory() {
    state = null;
  }
}

// 🎯 Like Post Action Provider
@riverpod
class BlogPostLikeNotifier extends _$BlogPostLikeNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  // Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
  //   state = const AsyncValue.loading();

  //   try {
  //     final likeBlogPostUseCase = ref.read(likeBlogPostProvider);

  //     if (isCurrentlyLiked) {
  //       // TODO: Implement unlike when repository supports it
  //       debugPrint('Unlike not implemented yet');
  //     } else {
  //       final result = await likeBlogPostUseCase(postId);
  //       result.fold((failure) => throw failure, (updatedPost) {
  //         // Invalidate related providers to refresh data
  //         ref.invalidate(blogPostProvider(postId));
  //         ref.invalidate(blogPostsProvider);
  //       });
  //     }

  //     state = const AsyncValue.data(null);
  //   } catch (e) {
  //     // Mock like action
  //     debugPrint('Like action not available, using mock action: $e');
  //     await Future.delayed(const Duration(milliseconds: 300));

  //     // Simulate successful like
  //     ref.invalidate(blogPostProvider(postId));
  //     state = const AsyncValue.data(null);
  //   }
  // }
}

// 🎯 Action Providers for UI Components

// Like action provider - to be called from UI
@riverpod
Future<void> likeBlogPostAction(
  LikeBlogPostActionRef ref,
  String postId,
) async {
  try {
    final repository = ref.read(blogRepositoryProvider);
    final result = await repository.likeBlogPost(postId);
    result.fold((failure) => throw failure, (_) {
      // Invalidate related providers to refresh UI
      ref.invalidate(blogPostProvider(postId));
      ref.invalidate(blogPostsProvider);
    });
  } catch (e) {
    debugPrint('Like action failed, using mock: $e');
    // Mock successful like
    await Future.delayed(const Duration(milliseconds: 300));
    ref.invalidate(blogPostProvider(postId));
  }
}

// Bookmark action provider - to be called from UI
@riverpod
Future<void> bookmarkBlogPostAction(
  BookmarkBlogPostActionRef ref,
  String postId,
) async {
  try {
    final repository = ref.read(blogRepositoryProvider);
    final result = await repository.bookmarkBlogPost(postId);
    result.fold((failure) => throw failure, (_) {
      // Invalidate related providers to refresh UI
      ref.invalidate(blogPostProvider(postId));
    });
  } catch (e) {
    debugPrint('Bookmark action failed, using mock: $e');
    // Mock successful bookmark
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

// 🎯 Missing Providers for UI Components

// Bookmark blog post provider
@riverpod
Future<void> bookmarkBlogPost(Ref ref, String postId) async {
  try {
    final repository = ref.watch(blogRepositoryProvider);
    final result = await repository.bookmarkBlogPost(postId);
    result.fold((failure) => throw failure, (_) => {});
  } catch (e) {
    debugPrint('Bookmark functionality not available: $e');
    // Mock implementation - do nothing for now
  }
}

// Filtered blog posts provider
@riverpod
Future<List<BlogPost>> filteredBlogPosts(
  FilteredBlogPostsRef ref, {
  String? categoryId,
  String? searchQuery,
}) async {
  try {
    final allPosts = await ref.watch(blogPostsProvider.future);

    List<BlogPost> filtered = allPosts; // Filter by category if specified
    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((post) => post.category == categoryId).toList();
    }

    // Filter by search query if specified
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (post) =>
                post.title.toLowerCase().contains(query) ||
                post.excerpt.toLowerCase().contains(query) ||
                post.content.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  } catch (e) {
    debugPrint('Filtered posts not available: $e');
    return [];
  }
}

// Like blog post provider - return the use case instead of calling it directly
@riverpod
LikeBlogPost likeBlogPostProvider(LikeBlogPostProviderRef ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return LikeBlogPost(repository);
}

// Search blog posts use case provider
@riverpod
SearchBlogPosts searchBlogPostsUseCase(SearchBlogPostsUseCaseRef ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return SearchBlogPosts(repository);
}

// Search blog posts provider for UI - takes parameters and returns results
@riverpod
Future<List<BlogPost>> searchBlogPostsResults(
  SearchBlogPostsResultsRef ref, {
  required String query,
  String? categoryId,
}) async {
  try {
    final repository = ref.watch(blogRepositoryProvider);
    final result = await repository.searchBlogPosts(
      query,
      category: categoryId,
    );
    return result.fold((failure) => throw failure, (posts) => posts);
  } catch (e) {
    debugPrint('Search functionality not available, using mock data: $e');
    // Mock search - filter mock posts by query
    final allPosts = _generateMockBlogPosts();
    return allPosts
        .where(
          (post) =>
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.content.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

// 📚 Mock Data Generation Functions
List<BlogPost> _generateMockBlogPosts() => List.generate(10, (index) {
    final postId = 'blog_post_${index + 1}';
    final now = DateTime.now();

    return BlogPost(
      id: postId,
      title: _mockTitles[index % _mockTitles.length],
      content: _generateMockContent(index),
      excerpt: _mockExcerpts[index % _mockExcerpts.length],
      authorId: 'author_${(index % 3) + 1}',
      authorName: _mockAuthors[index % _mockAuthors.length],
      authorAvatar:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=author${index % 3}',
      createdAt: now.subtract(Duration(days: index + 1)),
      updatedAt: now.subtract(Duration(days: index)),
      publishedAt: now.subtract(Duration(days: index + 1, hours: 2)),
      status: BlogPostStatus.published,
      tags: _mockTags.take(3).toList(),
      category: _mockCategories()[index % _mockCategories().length].name,
      featuredImage: 'https://picsum.photos/800/400?random=${index + 1}',
      viewCount: (index + 1) * 150 + (index * 23),
      likeCount: (index + 1) * 12 + (index * 3),
      commentCount: (index + 1) * 5 + index,
      isLiked: index % 3 == 0,
      isBookmarked: index % 4 == 0,
      slug: _mockTitles[index % _mockTitles.length].toLowerCase().replaceAll(
        ' ',
        '-',
      ),
    );
  });

BlogPost _generateMockBlogPost(String postId) {
  final index = postId.hashCode % 10;
  final now = DateTime.now();

  return BlogPost(
    id: postId,
    title: _mockTitles[index % _mockTitles.length],
    content: _generateMockContent(index),
    excerpt: _mockExcerpts[index % _mockExcerpts.length],
    authorId: 'author_${(index % 3) + 1}',
    authorName: _mockAuthors[index % _mockAuthors.length],
    authorAvatar:
        'https://api.dicebear.com/7.x/avataaars/svg?seed=author${index % 3}',
    createdAt: now.subtract(Duration(days: index + 1)),
    updatedAt: now.subtract(Duration(days: index)),
    publishedAt: now.subtract(Duration(days: index + 1, hours: 2)),
    status: BlogPostStatus.published,
    tags: _mockTags.take(3).toList(),
    category: _mockCategories()[index % _mockCategories().length].name,
    featuredImage: 'https://picsum.photos/800/400?random=${index + 10}',
    viewCount: (index + 1) * 150 + (index * 23),
    likeCount: (index + 1) * 12 + (index * 3),
    commentCount: (index + 1) * 5 + index,
    isLiked: index % 3 == 0,
    isBookmarked: index % 4 == 0,
    slug: _mockTitles[index % _mockTitles.length].toLowerCase().replaceAll(
      ' ',
      '-',
    ),
  );
}

List<BlogCategory> _mockCategories() {
  final categories = [
    'Technology',
    'Business',
    'Design',
    'Development',
    'Marketing',
  ];

  return categories
      .map(
        (name) => BlogCategory(
          id: name.toLowerCase(),
          name: name,
          slug: name.toLowerCase(),
          description: 'Everything about $name',
          color: _categoryColors[name] ?? '#6366f1',
          icon: _categoryIcons[name],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          postCount: (name.hashCode % 50) + 10,
          isActive: true,
        ),
      )
      .toList();
}

List<BlogComment> _generateMockComments(String postId) => List.generate(5, (index) {
    final now = DateTime.now();

    return BlogComment(
      id: 'comment_${postId}_$index',
      postId: postId,
      authorId: 'commenter_$index',
      authorName: _mockCommenters[index % _mockCommenters.length],
      authorAvatar:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=comment$index',
      content: _mockCommentTexts[index % _mockCommentTexts.length],
      createdAt: now.subtract(Duration(hours: index + 1)),
      updatedAt: now.subtract(Duration(hours: index + 1)),
      parentId: index > 2 ? 'comment_${postId}_0' : null, // Some replies
      likeCount: index * 3,
      isLiked: index % 2 == 0,
      isEdited: false,
      isActive: true,
    );
  });

List<BlogPost> _generateMockSearchResults(String query) {
  final allPosts = _generateMockBlogPosts();
  return allPosts
      .where(
        (post) =>
            post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.content.toLowerCase().contains(query.toLowerCase()) ||
            post.tags.any(
              (tag) => tag.toLowerCase().contains(query.toLowerCase()),
            ),
      )
      .toList();
}

String _generateMockContent(int index) {
  final paragraphs = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
    "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
  ];

  return paragraphs.take((index % 3) + 2).join('\n\n');
}

// Mock Data Constants
const _mockTitles = [
  'The Future of Mobile Development',
  'Building Scalable Flutter Applications',
  'Clean Architecture in Practice',
  'State Management Best Practices',
  'Performance Optimization Tips',
  'Design System Implementation',
  'Testing Strategies for Mobile Apps',
  'CI/CD for Flutter Projects',
  'Security Best Practices',
  'User Experience Design Principles',
];

const _mockExcerpts = [
  'Discover the latest trends and technologies shaping the future of mobile development.',
  'Learn how to build applications that can scale to millions of users.',
  'A practical guide to implementing clean architecture patterns.',
  'Best practices for managing state in complex applications.',
  'Tips and tricks for optimizing app performance.',
];

const _mockAuthors = [
  'John Doe',
  'Jane Smith',
  'Mike Johnson',
  'Sarah Wilson',
  'David Brown',
];

const _mockTags = [
  'Flutter',
  'Dart',
  'Mobile',
  'Development',
  'Architecture',
  'Performance',
];

const _mockCommenters = [
  'Alice Cooper',
  'Bob Builder',
  'Charlie Brown',
  'Diana Prince',
  'Eve Adams',
];

const _mockCommentTexts = [
  'Great article! Very informative and well-written.',
  'Thanks for sharing this. It helped me solve a problem I was facing.',
  'I have a different perspective on this topic. What do you think about...',
  'Excellent examples and clear explanations.',
  'Looking forward to more content like this!',
];

const _categoryColors = {
  'Technology': '#3b82f6',
  'Business': '#10b981',
  'Design': '#f59e0b',
  'Development': '#8b5cf6',
  'Marketing': '#ef4444',
};

const _categoryIcons = {
  'Technology': '💻',
  'Business': '📊',
  'Design': '🎨',
  'Development': '⚡',
  'Marketing': '📈',
};

// Helper function to generate mock categories
List<BlogCategory> _generateMockCategories() => [
    BlogCategory(
      id: '1',
      name: 'Technology',
      slug: 'technology',
      description: 'Latest technology trends and innovations',
      color: '#3b82f6',
      icon: '💻',
      postCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    BlogCategory(
      id: '2',
      name: 'Business',
      slug: 'business',
      description: 'Business insights and strategies',
      color: '#10b981',
      icon: '📊',
      postCount: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    BlogCategory(
      id: '3',
      name: 'Design',
      slug: 'design',
      description: 'UI/UX design principles and trends',
      color: '#f59e0b',
      icon: '🎨',
      postCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    BlogCategory(
      id: '4',
      name: 'Development',
      slug: 'development',
      description: 'Software development tutorials',
      color: '#8b5cf6',
      icon: '⚡',
      postCount: 30,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    BlogCategory(
      id: '5',
      name: 'Marketing',
      slug: 'marketing',
      description: 'Digital marketing strategies',
      color: '#ef4444',
      icon: '📈',
      postCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];
