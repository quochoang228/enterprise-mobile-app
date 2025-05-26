import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

// Helper function to convert double size to AppAvatarSize
AppAvatarSize _getAppAvatarSizeFromDouble(double size) {
  // Use >= comparisons and check in descending order for correct size mapping
  if (size >= AppDimensions.avatarXXXL) return AppAvatarSize.xxxl;
  if (size >= AppDimensions.avatarXXL) return AppAvatarSize.xxl;
  if (size >= AppDimensions.avatarXL) return AppAvatarSize.xl;
  if (size >= AppDimensions.avatarLG) return AppAvatarSize.lg;
  if (size >= AppDimensions.avatarMD) return AppAvatarSize.md;
  if (size >= AppDimensions.avatarSM) return AppAvatarSize.sm;
  return AppAvatarSize.xs;
}

class UserAvatar extends StatelessWidget {

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.size = 48,
    this.onTap,
  });
  final String? imageUrl;
  final String? fallbackText;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AppAvatar(
        imageUrl: imageUrl,
        size: _getAppAvatarSizeFromDouble(size), // Use helper function
        initials: fallbackText ?? '?', // Changed from fallbackText to initials
      ),
    );
}

class UserCard extends StatelessWidget {

  const UserCard({
    required this.name, required this.email, super.key,
    this.imageUrl,
    this.onTap,
  });
  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: imageUrl,
                fallbackText: name.isNotEmpty ? name[0] : '?',
                size: 56,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: AppTypography.bodyMedium.copyWith(
                        // Changed from body2 to bodyMedium
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
}

class UserListTile extends StatelessWidget {

  const UserListTile({
    required this.name, required this.subtitle, super.key,
    this.imageUrl,
    this.trailing,
    this.onTap,
  });
  final String name;
  final String subtitle;
  final String? imageUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
      leading: UserAvatar(
        imageUrl: imageUrl,
        fallbackText: name.isNotEmpty ? name[0] : '?',
        size: 40,
      ),
      title: Text(
        name,
        style: AppTypography.bodyLarge,
      ), // Changed from body1 to bodyLarge
      subtitle: Text(
        subtitle,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ), // Changed from body2 to bodyMedium
      ),
      trailing: trailing,
      onTap: onTap,
    );
}
