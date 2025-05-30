/// Blog Feature Module
///
/// This library provides a complete blog functionality including:
/// - Blog posts listing and filtering
/// - Blog post detail view with comments
/// - Search functionality
/// - Category management
/// - Clean Architecture implementation with Riverpod state management
library blog;

// Domain Layer Exports
export 'src/domain/entities/blog_post.dart';
export 'src/domain/entities/blog_category.dart';
export 'src/domain/entities/blog_comment.dart';
export 'src/domain/repositories/blog_repository.dart';
export 'src/domain/usecases/get_blog_posts.dart';
export 'src/domain/usecases/get_blog_post_by_id.dart';
export 'src/domain/usecases/like_blog_post.dart';
export 'src/domain/usecases/get_blog_comments.dart';
export 'src/domain/usecases/search_blog_posts.dart';

// Data Layer Exports
export 'src/data/models/blog_post_model.dart';
export 'src/data/models/blog_category_model.dart';
export 'src/data/models/blog_comment_model.dart';
export 'src/data/datasources/blog_local_datasource.dart';
export 'src/data/datasources/blog_remote_datasource.dart';
export 'src/data/repositories/blog_repository_impl.dart';

// Presentation Layer Exports
export 'src/presentation/pages/blog_list_page.dart';
export 'src/presentation/pages/blog_detail_page.dart';
export 'src/presentation/pages/blog_search_page.dart';
export 'src/presentation/widgets/blog_post_card.dart';
export 'src/presentation/widgets/category_list_widget.dart';
export 'src/presentation/widgets/blog_comment_widget.dart';
export 'src/presentation/providers/blog_providers.dart';
