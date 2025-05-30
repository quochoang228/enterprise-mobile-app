import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_management/user_management.dart';

class UserExamplePage extends ConsumerWidget {
  const UserExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management Demo')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _UserProfileSection(),
            SizedBox(height: 20),
            _UserListSection(),
            SizedBox(height: 20),
            _UserActionsSection(),
          ],
        ),
      ),
    );
  }
}

class _UserProfileSection extends ConsumerWidget {
  const _UserProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Sử dụng provider từ user_management package
    final currentUserAsync = ref.watch(currentUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Current User Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            currentUserAsync.when(
              data: (user) => user != null
                  ? UserCard(
                      name: user.fullName,
                      email: user.email,
                    ) // Widget từ user_management
                  : const Text('No user logged in'),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListSection extends ConsumerWidget {
  const _UserListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔍 Sử dụng search functionality từ user_management
    final searchQuery = ref.watch(userSearchQueryProvider);
    final usersAsync = ref.watch(searchUsersProvider(searchQuery));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 User Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                ref.read(userSearchQueryProvider.notifier).state = query;
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: usersAsync.when(
                data: (users) => ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return UserListTile(
                      name: users[index].fullName,
                      subtitle: users[index].id,
                    ); // Widget từ user_management
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserActionsSection extends ConsumerWidget {
  const _UserActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ User Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateUserProfile(ref),
                    child: const Text('Update Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _refreshUserData(ref),
                    child: const Text('Refresh Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserProfile(WidgetRef ref) async {
    // 🔄 Sử dụng use case từ user_management
    final updateUser = ref.read(updateUserProvider);
    final result = await updateUser.call('current_user_id', {
      'name': 'Updated Name',
      'updated_at': DateTime.now().toIso8601String(),
    });

    result.fold(
      (failure) => debugPrint('Update failed: ${failure.message}'),
      (user) => debugPrint('User updated: ${user.fullName}'),
    );
  }

  void _refreshUserData(WidgetRef ref) {
    // 🔄 Invalidate providers để reload data
    ref.invalidate(currentUserProvider);
    ref.invalidate(searchUsersProvider);
  }
}

// 🎯 Additional providers for search functionality
final userSearchQueryProvider = StateProvider<String>((ref) => '');

final searchUsersProvider = FutureProvider.family<List<User>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  final searchUsers = ref.read(getUserByIdProvider);
  final result = await searchUsers.call(query);

  return result.fold((failure) => throw failure, (users) => [users]);
});
