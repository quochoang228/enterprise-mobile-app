import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/blog_comment.dart';

class BlogCommentWidget extends StatelessWidget {
  final BlogComment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onReport;
  final int nestingLevel;
  final bool showReplies;

  const BlogCommentWidget({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onReport,
    this.nestingLevel = 0,
    this.showReplies = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftPadding = nestingLevel * 24.0;

    return Container(
      margin: EdgeInsets.only(left: leftPadding, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: nestingLevel > 0 ? 14 : 18,
            backgroundImage: comment.authorAvatar != null
                ? CachedNetworkImageProvider(comment.authorAvatar!)
                : null,
            child: comment.authorAvatar == null
                ? Text(
                    comment.authorName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: nestingLevel > 0 ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author and timestamp
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: nestingLevel > 0 ? 13 : 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: nestingLevel > 0 ? 11 : 12,
                      ),
                    ),
                    if (comment.isEdited) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(edited)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: nestingLevel > 0 ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Action buttons
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              comment.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: nestingLevel > 0 ? 14 : 16,
                              color: comment.isLiked
                                  ? Colors.red
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            if (comment.likeCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                _formatNumber(comment.likeCount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: nestingLevel > 0 ? 11 : 12,
                                  color: comment.isLiked
                                      ? Colors.red
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Reply button
                    if (nestingLevel < 2) // Limit reply nesting
                      InkWell(
                        onTap: onReply,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            'Reply',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: nestingLevel > 0 ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    const Spacer(),

                    // More options
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        size: nestingLevel > 0 ? 16 : 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              const Text('Report'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'report':
                            onReport?.call();
                            break;
                        }
                      },
                    ),
                  ],
                ),

                // Replies
                if (showReplies && comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...comment.replies.map(
                    (reply) => BlogCommentWidget(
                      comment: reply,
                      nestingLevel: nestingLevel + 1,
                      onLike: () {
                        // Handle reply like
                      },
                      onReply: () {
                        // Handle reply to reply
                      },
                      onReport: () {
                        // Handle reply report
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

class CommentInputWidget extends StatefulWidget {
  final String? replyToAuthor;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onCancel;

  const CommentInputWidget({
    super.key,
    this.replyToAuthor,
    this.onSubmit,
    this.onCancel,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.replyToAuthor != null) {
      _controller.text = '@${widget.replyToAuthor} ';
      _isExpanded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_isExpanded) {
        setState(() {
          _isExpanded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.replyToAuthor != null) ...[
              Row(
                children: [
                  Icon(Icons.reply, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Replying to ${widget.replyToAuthor}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 40,
                      maxHeight: _isExpanded ? 120 : 40,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: _isExpanded ? null : 1,
                      decoration: InputDecoration(
                        hintText: widget.replyToAuthor != null
                            ? 'Write a reply...'
                            : 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: _canSubmit() ? _submitComment : null,
                    icon: Icon(
                      Icons.send,
                      color: _canSubmit()
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
                  const Spacer(),
                  Text(
                    '${_controller.text.length}/500',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _controller.text.length > 500
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    final text = _controller.text.trim();
    if (widget.replyToAuthor != null) {
      final replyPrefix = '@${widget.replyToAuthor} ';
      return text.length > replyPrefix.length && text.length <= 500;
    }
    return text.isNotEmpty && text.length <= 500;
  }

  void _submitComment() {
    if (_canSubmit()) {
      widget.onSubmit?.call(_controller.text.trim());
      _controller.clear();
      setState(() {
        _isExpanded = false;
      });
      _focusNode.unfocus();
    }
  }

  void _cancel() {
    _controller.clear();
    setState(() {
      _isExpanded = false;
    });
    _focusNode.unfocus();
    widget.onCancel?.call();
  }
}
