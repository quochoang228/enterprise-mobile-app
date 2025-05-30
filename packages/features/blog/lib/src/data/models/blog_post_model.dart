import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/blog_post.dart';

part 'blog_post_model.freezed.dart';
part 'blog_post_model.g.dart';

@freezed
class BlogPostModel with _$BlogPostModel {
  const factory BlogPostModel({
    required String id,
    required String title,
    required String content,
    required String excerpt,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    required BlogPostStatus status,
    required List<String> tags,
    required String category,
    @JsonKey(name: 'view_count') required int viewCount,
    @JsonKey(name: 'like_count') required int likeCount,
    @JsonKey(name: 'comment_count') required int commentCount,
    @JsonKey(name: 'author_avatar') String? authorAvatar,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
    @JsonKey(name: 'featured_image') String? featuredImage,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'is_bookmarked') @Default(false) bool isBookmarked,
    String? slug,
    Map<String, dynamic>? metadata,
  }) = _BlogPostModel;

  // Convert from domain entity
  factory BlogPostModel.fromEntity(BlogPost entity) => BlogPostModel(
    id: entity.id,
    title: entity.title,
    content: entity.content,
    excerpt: entity.excerpt,
    authorId: entity.authorId,
    authorName: entity.authorName,
    authorAvatar: entity.authorAvatar,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    publishedAt: entity.publishedAt,
    status: entity.status,
    tags: entity.tags,
    category: entity.category,
    featuredImage: entity.featuredImage,
    viewCount: entity.viewCount,
    likeCount: entity.likeCount,
    commentCount: entity.commentCount,
    isLiked: entity.isLiked,
    isBookmarked: entity.isBookmarked,
    slug: entity.slug,
    metadata: entity.metadata,
  );

  const BlogPostModel._();

  factory BlogPostModel.fromJson(Map<String, dynamic> json) =>
      _$BlogPostModelFromJson(json);

  // Convert to domain entity
  BlogPost toEntity() => BlogPost(
    id: id,
    title: title,
    content: content,
    excerpt: excerpt,
    authorId: authorId,
    authorName: authorName,
    authorAvatar: authorAvatar,
    createdAt: createdAt,
    updatedAt: updatedAt,
    publishedAt: publishedAt,
    status: status,
    tags: tags,
    category: category,
    featuredImage: featuredImage,
    viewCount: viewCount,
    likeCount: likeCount,
    commentCount: commentCount,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
    slug: slug,
    metadata: metadata,
  );
}
