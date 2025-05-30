import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_post.freezed.dart';

@freezed
class BlogPost with _$BlogPost {
  const factory BlogPost({
    required String id,
    required String title,
    required String content,
    required String excerpt,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
    required BlogPostStatus status,
    required List<String> tags,
    required String category,
    String? featuredImage,
    required int viewCount,
    required int likeCount,
    required int commentCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
    String? slug,
    Map<String, dynamic>? metadata,
  }) = _BlogPost;

  const BlogPost._();

  // Business logic methods
  bool get isPublished => status == BlogPostStatus.published;
  bool get isDraft => status == BlogPostStatus.draft;
  bool get isArchived => status == BlogPostStatus.archived;

  String get formattedPublishDate {
    if (publishedAt == null) return 'Not published';

    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays > 7) {
      return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get readingTime {
    const wordsPerMinute = 200;
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return '$minutes min read';
  }
}

enum BlogPostStatus { draft, published, archived, scheduled }
