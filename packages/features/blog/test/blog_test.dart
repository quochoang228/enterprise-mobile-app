import 'package:flutter_test/flutter_test.dart';
import 'package:blog/blog.dart';

void main() {
  group('Blog Feature Tests', () {
    test('BlogPost entity should be created correctly', () {
      final post = BlogPost(
        id: '1',
        title: 'Test Post',
        content: 'Test content',
        excerpt: 'Test excerpt',
        authorId: 'author1',
        authorName: 'Test Author',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publishedAt: DateTime.now(),
        status: BlogPostStatus.published,
        tags: ['flutter', 'test'],
        category: 'Technology',
        viewCount: 100,
        likeCount: 10,
        commentCount: 5,
        isLiked: false,
        isBookmarked: false,
        slug: 'test-post',
      );

      expect(post.id, '1');
      expect(post.title, 'Test Post');
      expect(post.category, 'Technology');
      expect(post.tags.length, 2);
      expect(post.readingTime, contains('min read'));
    });

    test('BlogCategory entity should be created correctly', () {
      final category = BlogCategory(
        id: '1',
        name: 'Technology',
        slug: 'technology',
        description: 'Tech posts',
        color: '#3b82f6',
        
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        postCount: 10,
      );

      expect(category.id, '1');
      expect(category.name, 'Technology');
      expect(category.slug, 'technology');
    });

    test('BlogComment entity should be created correctly', () {
      final comment = BlogComment(
        id: '1',
        postId: 'post1',
        content: 'Great post!',
        authorId: 'user1',
        authorName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 5,
        isLiked: false,
      );

      expect(comment.id, '1');
      expect(comment.content, 'Great post!');
      expect(comment.authorName, 'Test User');
      expect(comment.formattedDate, isNotEmpty);
    });
  });
}
