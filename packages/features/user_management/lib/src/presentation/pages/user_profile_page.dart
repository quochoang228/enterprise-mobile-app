import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../providers/user_provider.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: userState.when(
        data: (user) => _buildUserProfile(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, user) => SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          Center(
            child: AppAvatar(
              imageUrl: user.profilePictureUrl,
              size: AppAvatarSize.xl, // Changed from int to AppAvatarSize enum
              initials: user.name.isNotEmpty
                  ? user.name[0]
                  : '?', // Used initials instead of fallbackText
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // User Details
          _buildDetailCard('Name', user.name),
          const SizedBox(height: AppSpacing.md),
          _buildDetailCard('Email', user.email),
          const SizedBox(height: AppSpacing.md),
          _buildDetailCard('Phone', user.phoneNumber ?? 'Not provided'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailCard('Bio', user.bio ?? 'No bio available'),

          const SizedBox(height: AppSpacing.xl),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Edit Profile',
              onPressed: () {
                // Navigate to edit profile page
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildDetailCard(String label, String value) => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.bodyLarge,
            ), // Changed from body1 to bodyLarge
          ],
        ),
      ),
    );

  Widget _buildErrorState(BuildContext context, String error) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Error loading profile', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ), // Changed from body2 to bodyMedium
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Retry',
            onPressed: () {
              // Retry loading user data
            },
          ),
        ],
      ),
    );
}
