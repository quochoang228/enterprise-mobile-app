import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/blog_comment.dart';
import '../../domain/entities/blog_post.dart';
import '../providers/blog_providers.dart';

class BlogDetailPage extends ConsumerStatefulWidget {

  const BlogDetailPage({required this.postId, super.key});
  final String postId;

  @override
  ConsumerState<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends ConsumerState<BlogDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.offset > 200;
      if (_isAppBarCollapsed != isCollapsed) {
        setState(() {
          _isAppBarCollapsed = isCollapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(blogPostProvider(widget.postId));
    final commentsAsync = ref.watch(blogCommentsProvider(widget.postId));
    return Scaffold(
      body: postAsync.when(
        data: (post) => post != null
            ? _buildContent(post, commentsAsync)
            : _buildPostNotFound(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildContent(
    BlogPost post,
    AsyncValue<List<BlogComment>> commentsAsync,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroImage(post),
            title: _isAppBarCollapsed
                ? Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            titlePadding: const EdgeInsets.only(
              left: 56,
              bottom: 16,
              right: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              onPressed: () => _toggleBookmark(post.id),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _sharePost(post),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (when not collapsed)
                if (!_isAppBarCollapsed) ...[
                  Text(
                    post.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Meta information
                _buildMetaInfo(post),
                const SizedBox(height: 24), // Content
                _buildPostContent(post),
                const SizedBox(height: 32),

                // Tags
                _buildTags(post),
                const SizedBox(height: 32),

                // Engagement actions
                _buildEngagementActions(post),
                const SizedBox(height: 32),

                // Related posts section placeholder
                _buildRelatedPostsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Comments section
        SliverToBoxAdapter(child: _buildCommentsSection(commentsAsync)),
      ],
    );
  }

  Widget _buildHeroImage(BlogPost post) {
    if (post.featuredImage == null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const Center(child: Icon(Icons.article, size: 64)),
      );
    }

    return CachedNetworkImage(
      imageUrl: post.featuredImage!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const Center(child: Icon(Icons.broken_image, size: 64)),
      ),
    );
  }

  Widget _buildMetaInfo(BlogPost post) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            post.category,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Author and date
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: post.authorAvatar != null
                  ? CachedNetworkImageProvider(post.authorAvatar!)
                  : null,
              child: post.authorAvatar == null
                  ? Text(post.authorName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${post.formattedPublishDate} • ${post.readingTime}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats
        Row(
          children: [
            _buildStatItem(Icons.visibility, post.viewCount),
            const SizedBox(width: 24),
            _buildStatItem(Icons.favorite, post.likeCount),
            const SizedBox(width: 24),
            _buildStatItem(Icons.chat_bubble_outline, post.commentCount),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          _formatNumber(count),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(BlogPost post) => Html(
      data: post.content,
      style: {
        'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        'p': Style(
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.6),
          margin: Margins.only(bottom: 16),
        ),
        'h1': Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 24, bottom: 16),
        ),
        'h2': Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 20, bottom: 12),
        ),
        'h3': Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 16, bottom: 8),
        ),
        'blockquote': Style(
          padding: HtmlPaddings.symmetric(horizontal: 16, vertical: 12),
          margin: Margins.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        'code': Style(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
          fontFamily: 'monospace',
        ),
        'pre': Style(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          padding: HtmlPaddings.all(16),
          margin: Margins.symmetric(vertical: 16),
          fontFamily: 'monospace',
        ),
      },
    );

  Widget _buildTags(BlogPost post) {
    if (post.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: post.tags
              .map(
                (tag) => Chip(
                  label: Text(tag, style: theme.textTheme.labelMedium),
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEngagementActions(BlogPost post) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
              label: _formatNumber(post.likeCount),
              isActive: post.isLiked,
              onPressed: () => _toggleLike(post.id),
            ),
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: _formatNumber(post.commentCount),
              onPressed: _scrollToComments,
            ),
            _buildActionButton(
              icon: Icons.share,
              label: 'Share',
              onPressed: () => _sharePost(post),
            ),
          ],
        ),
      ),
    );

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed, bool isActive = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedPostsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Posts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Mock data
            itemBuilder: (context, index) => Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: theme.colorScheme.surfaceContainer,
                          child: const Center(child: Icon(Icons.article)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Related Post Title ${index + 1}',
                                style: theme.textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                '2 min read',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(AsyncValue<List<BlogComment>> commentsAsync) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainer.withValues(alpha:0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildCommentInput(),
          commentsAsync.when(
            data: _buildCommentsList,
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load comments',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _postComment, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<BlogComment> comments) => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(comment);
      },
    );

  Widget _buildCommentItem(BlogComment comment) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.authorAvatar != null
                ? CachedNetworkImageProvider(comment.authorAvatar!)
                : null,
            child: comment.authorAvatar == null
                ? Text(comment.authorName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleCommentLike(comment.id),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked
                                ? Colors.red
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(comment.likeCount),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _replyToComment(comment),
                      child: Text(
                        'Reply',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load post',
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
                ref.invalidate(blogPostProvider(widget.postId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostNotFound() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Post not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The requested blog post could not be found.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    }
    if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '${(number / 1000000).toStringAsFixed(1)}M';
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

  void _scrollToComments() {
    // Scroll to comments section
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isNotEmpty) {
      // Implement comment posting
      _commentController.clear();
    }
  }

  void _toggleCommentLike(String commentId) {
    // Implement comment like functionality
  }

  void _replyToComment(BlogComment comment) {
    // Implement reply functionality
    _commentController.text = '@${comment.authorName} ';
  }
}
