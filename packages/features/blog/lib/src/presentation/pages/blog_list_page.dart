import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/blog_post.dart';
import '../../domain/entities/blog_category.dart';
import '../providers/blog_providers.dart';
import '../widgets/blog_post_card.dart';

class BlogListPage extends ConsumerStatefulWidget {
  const BlogListPage({super.key});

  @override
  ConsumerState<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends ConsumerState<BlogListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategoryId = '';
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(blogCategoriesProvider);
    final postsAsync = ref.watch(
      filteredBlogPostsProvider(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            title: _isSearching
                ? _buildSearchField()
                : const Text(
                    'Blog',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
            bottom: categoriesAsync.when(
              data: (categories) => _buildCategoryTabs(categories),
              loading: () => const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox.shrink(),
              ),
              error: (_, __) => const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ],
        body: postsAsync.when(
          data: (posts) => _buildPostsList(posts),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(error),
        ),
      ),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search posts...',
        border: InputBorder.none,
        hintStyle: TextStyle(fontSize: 16),
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  PreferredSizeWidget? _buildCategoryTabs(List<BlogCategory> categories) {
    final allCategories = [
      BlogCategory(
        id: '',
        name: 'All',
        slug: 'all',
        description: 'All posts',
        color: '#6366f1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        postCount: 0,
      ),
      ...categories,
    ];

    if (allCategories.length <= 1) return null;

    return TabBar(
      controller: TabController(
        length: allCategories.length,
        vsync: this,
        initialIndex: allCategories
            .indexWhere((c) => c.id == _selectedCategoryId)
            .clamp(0, allCategories.length - 1),
      ),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: allCategories
          .map(
            (category) => Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedCategoryId == category.id
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category.icon != null) ...[
                      Text(
                        category.icon!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      category.name,
                      style: TextStyle(
                        color: _selectedCategoryId == category.id
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
      onTap: (index) {
        setState(() {
          _selectedCategoryId = allCategories[index].id;
        });
      },
      indicator: const BoxDecoration(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPostsList(List<BlogPost> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(blogPostsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return BlogPostCard(
            post: post,
            onTap: () => _navigateToPostDetail(post.id),
            onLike: () => _toggleLike(post.id),
            onBookmark: () => _toggleBookmark(post.id),
            onShare: () => _sharePost(post),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.article_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No posts found for "$_searchQuery"'
                : 'No posts available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try different keywords'
                : 'Check back later for new content',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(blogPostsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget? _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showButton =
            _scrollController.hasClients && _scrollController.offset > 200;

        if (!showButton) return const SizedBox.shrink();

        return FloatingActionButton.small(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Icon(Icons.keyboard_arrow_up),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Filter Posts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Add filter options here
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Sort by Date'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        // Implement sort functionality
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text('Most Liked'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        // Implement sort functionality
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text('Most Viewed'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        // Implement sort functionality
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPostDetail(String postId) {
    context.go('/blog/post/$postId');
  }

  void _toggleLike(String postId) {
    ref.read(likeBlogPostActionProvider(postId));
  }

  void _toggleBookmark(String postId) {
    ref.read(bookmarkBlogPostActionProvider(postId));
  }

  void _sharePost(BlogPost post) {
    // Implement share functionality
    // Could use share_plus package
  }
}
