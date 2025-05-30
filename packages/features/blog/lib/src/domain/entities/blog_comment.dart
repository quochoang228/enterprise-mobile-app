import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_comment.freezed.dart';

@freezed
class BlogComment with _$BlogComment {
  const factory BlogComment({
    required String id,
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int likeCount,
    String? authorAvatar,
    String? parentId, // For nested comments
    @Default(false) bool isLiked,
    @Default(false) bool isEdited,
    @Default(true) bool isActive,
    @Default([]) List<BlogComment> replies, // Nested replies
    Map<String, dynamic>? metadata,
  }) = _BlogComment;

  const BlogComment._();

  // Business logic methods
  bool get isReply => parentId != null;
  bool get isTopLevel => parentId == null;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
