import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/blog_comment.dart';

part 'blog_comment_model.freezed.dart';
part 'blog_comment_model.g.dart';

@freezed
class BlogCommentModel with _$BlogCommentModel {

  // Convert from domain entity
  factory BlogCommentModel.fromEntity(BlogComment entity) => BlogCommentModel(
    id: entity.id,
    postId: entity.postId,
    authorId: entity.authorId,
    authorName: entity.authorName,
    authorAvatar: entity.authorAvatar,
    content: entity.content,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    parentId: entity.parentId,
    likeCount: entity.likeCount,
    isLiked: entity.isLiked,
    isEdited: entity.isEdited,
    isActive: entity.isActive,
    metadata: entity.metadata,
  );
  const factory BlogCommentModel({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'author_name') required String authorName,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'like_count') required int likeCount,
    @JsonKey(name: 'author_avatar') String? authorAvatar,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    Map<String, dynamic>? metadata,
  }) = _BlogCommentModel;

  const BlogCommentModel._();

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) =>
      _$BlogCommentModelFromJson(json);

  // Convert to domain entity
  BlogComment toEntity() => BlogComment(
    id: id,
    postId: postId,
    authorId: authorId,
    authorName: authorName,
    authorAvatar: authorAvatar,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    parentId: parentId,
    likeCount: likeCount,
    isLiked: isLiked,
    isEdited: isEdited,
    isActive: isActive,
    metadata: metadata,
  );
}
