import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/blog_category.dart';
import '../providers/blog_providers.dart';

class CategoryListWidget extends ConsumerWidget {

  const CategoryListWidget({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.showAllOption = true,
    this.scrollDirection = ScrollDirection.horizontal,
  });
  final String? selectedCategoryId;
  final ValueChanged<String?>? onCategorySelected;
  final bool showAllOption;
  final ScrollDirection scrollDirection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(blogCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _buildCategoryList(context, categories),
      loading: _buildLoadingState,
      error: (error, stackTrace) => _buildErrorState(context, error),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<BlogCategory> categories,
  ) {
    final _ = Theme.of(context);
    final allCategories = [
      if (showAllOption)
        BlogCategory(
          id: '',
          name: 'All',
          slug: 'all',
          description: 'All categories',
          color: '#6366f1',
          icon: '📚',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          postCount: 0,
        ),
      ...categories,
    ];

    if (scrollDirection == ScrollDirection.horizontal) {
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: allCategories.length,
          itemBuilder: (context, index) {
            final category = allCategories[index];
            return _buildCategoryChip(context, category);
          },
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          return _buildCategoryTile(context, category);
        },
      );
    }
  }

  Widget _buildCategoryChip(BuildContext context, BlogCategory category) {
    final theme = Theme.of(context);
    final isSelected = selectedCategoryId == category.id;

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
          onCategorySelected?.call(selected ? category.id : null);
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
  }

  Widget _buildCategoryTile(BuildContext context, BlogCategory category) {
    final theme = Theme.of(context);
    final isSelected = selectedCategoryId == category.id;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(
          int.parse(category.color?.replaceFirst('#', '0xFF') ?? '0xFF6366f1'),
        ),
        child: Text(
          category.icon ?? category.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        category.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(category.description ?? ''),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: () {
        onCategorySelected?.call(isSelected ? null : category.id);
      },
    );
  }

  Widget _buildLoadingState() => const SizedBox(
      height: 50,
      child: Center(child: CircularProgressIndicator()),
    );

  Widget _buildErrorState(BuildContext context, Object error) => Container(
      height: 50,
      padding: const EdgeInsets.all(16),
      child: Text(
        'Failed to load categories',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
}

enum ScrollDirection { horizontal, vertical }
