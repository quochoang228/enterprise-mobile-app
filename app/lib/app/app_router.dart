import 'package:blog/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_management/user_management.dart';
import '../features/example_usage_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ExampleUsagePage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfilePage(),
      ),
      // Blog routes
      GoRoute(path: '/blog', builder: (context, state) => const BlogListPage()),
      GoRoute(
        path: '/blog/search',
        builder: (context, state) => const BlogSearchPage(),
      ),
      GoRoute(
        path: '/blog/post/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return BlogDetailPage(postId: postId);
        },
      ),
      // Legacy route for backwards compatibility
      GoRoute(path: '/post', builder: (context, state) => const BlogListPage()),
    ],
  );
});

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise Mobile App'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Enterprise Mobile App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Built with Clean Architecture & Scalable Design',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
