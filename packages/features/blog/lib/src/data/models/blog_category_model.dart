import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/blog_category.dart';

part 'blog_category_model.freezed.dart';
part 'blog_category_model.g.dart';

@freezed
class BlogCategoryModel with _$BlogCategoryModel {
  const factory BlogCategoryModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? color,
    String? icon,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'post_count') required int postCount,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    Map<String, dynamic>? metadata,
  }) = _BlogCategoryModel;

  const BlogCategoryModel._();

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$BlogCategoryModelFromJson(json);

  // Convert to domain entity
  BlogCategory toEntity() => BlogCategory(
    id: id,
    name: name,
    slug: slug,
    description: description,
    color: color,
    icon: icon,
    createdAt: createdAt,
    updatedAt: updatedAt,
    postCount: postCount,
    isActive: isActive,
    metadata: metadata,
  );

  // Convert from domain entity
  factory BlogCategoryModel.fromEntity(BlogCategory entity) =>
      BlogCategoryModel(
        id: entity.id,
        name: entity.name,
        slug: entity.slug,
        description: entity.description,
        color: entity.color,
        icon: entity.icon,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        postCount: entity.postCount,
        isActive: entity.isActive,
        metadata: entity.metadata,
      );
}
