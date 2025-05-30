import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/blog_post.dart';
import '../../domain/entities/blog_category.dart';
import '../providers/blog_providers.dart';
import '../widgets/blog_post_card.dart';

class BlogSearchPage extends ConsumerStatefulWidget {
  const BlogSearchPage({super.key});

  @override
  ConsumerState<BlogSearchPage> createState() => _BlogSearchPageState();
}

class _BlogSearchPageState extends ConsumerState<BlogSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _currentQuery = '';
  String _selectedCategoryId = '';
  List<String> _searchHistory = [];
  bool _showHistory = true;

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _showHistory && _currentQuery.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      decoration: const InputDecoration(
        hintText: 'Search posts, authors, tags...',
        border: InputBorder.none,
        hintStyle: TextStyle(fontSize: 16),
      ),
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {
          _currentQuery = value;
          _showHistory = value.isEmpty;
        });
      },
      onSubmitted: _performSearch,
    );
  }

  Widget _buildFilters() {
    final categoriesAsync = ref.watch(blogCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _buildCategoryFilter(categories),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryFilter(List<BlogCategory> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final allCategories = [
      BlogCategory(
        id: '',
        name: 'All',
        slug: 'all',
        description: 'All categories',
        color: '#6366f1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        postCount: 0,
      ),
      ...categories,
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = _selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category.icon != null) ...[
                    Text(category.icon!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                  ],
                  Text(category.name),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = selected ? category.id : '';
                });
              },
              backgroundColor: theme.colorScheme.surfaceContainer,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHistory() {
    final theme = Theme.of(context);

    if (_searchHistory.isEmpty) {
      return _buildEmptyHistory();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _removeFromHistory(query),
                ),
                onTap: () => _selectHistoryItem(query),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Search for posts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find posts by title, content, author, or tags',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPopularSearches(),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    final popularSearches = [
      'Flutter',
      'Clean Architecture',
      'State Management',
      'Performance',
      'UI Design',
    ];

    return Column(
      children: [
        Text(
          'Popular searches',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches
              .map(
                (search) => ActionChip(
                  label: Text(search),
                  onPressed: () => _selectHistoryItem(search),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_currentQuery.isEmpty) {
      return const SizedBox.shrink();
    }
    final searchResultsAsync = ref.watch(
      searchBlogPostsResultsProvider(
        query: _currentQuery,
        categoryId: _selectedCategoryId,
      ),
    );

    return searchResultsAsync.when(
      data: (posts) => _buildResultsList(posts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  Widget _buildResultsList(List<BlogPost> posts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${posts.length} results for "$_currentQuery"',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (posts.isEmpty)
          _buildNoResults()
        else
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return BlogPostCard(
                  post: post,
                  onTap: () => _navigateToPost(post.id),
                  onLike: () => _toggleLike(post.id),
                  onBookmark: () => _toggleBookmark(post.id),
                  onShare: () => _sharePost(post),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            _buildSearchSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Remove filters',
      'Try broader terms',
      'Check spelling',
    ];

    return Column(
      children: [
        Text(
          'Suggestions:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• $suggestion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
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
            'Search failed',
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
              setState(() {
                _currentQuery = _searchController.text;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _currentQuery = query.trim();
      _showHistory = false;
    });

    _addToHistory(query.trim());
    _searchFocus.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _showHistory = true;
    });
    _searchFocus.requestFocus();
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  void _loadSearchHistory() {
    // In a real app, load from local storage
    setState(() {
      _searchHistory = [
        'Flutter development',
        'Clean architecture',
        'State management',
        'Performance optimization',
      ];
    });
  }

  void _addToHistory(String query) {
    setState(() {
      _searchHistory.remove(query); // Remove if exists
      _searchHistory.insert(0, query); // Add to beginning
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList(); // Keep only 10
      }
    });
    // In a real app, save to local storage
  }

  void _removeFromHistory(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
    // In a real app, update local storage
  }

  void _clearHistory() {
    setState(() {
      _searchHistory.clear();
    });
    // In a real app, clear local storage
  }

  void _navigateToPost(String postId) {
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
  }
}
