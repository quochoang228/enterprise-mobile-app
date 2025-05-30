import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_category.freezed.dart';

@freezed
class BlogCategory with _$BlogCategory {
  const factory BlogCategory({
    required String id,
    required String name,
    required String slug,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int postCount,
    String? description,
    String? color,
    String? icon,
    @Default(true) bool isActive,
    Map<String, dynamic>? metadata,
  }) = _BlogCategory;

  const BlogCategory._();

  // Business logic methods
  bool get hasIcon => icon != null && icon!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
}
