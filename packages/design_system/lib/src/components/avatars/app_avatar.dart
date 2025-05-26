import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_typography.dart';
import '../../tokens/app_dimensions.dart';

enum AppAvatarSize { xs, sm, md, lg, xl, xxl, xxxl }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final String? name;
  final AppAvatarSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final bool showBorder;
  final Color? borderColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.placeholder,
    this.showBorder = false,
    this.borderColor,
  });

  const AppAvatar.small({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.placeholder,
    this.showBorder = false,
    this.borderColor,
  }) : size = AppAvatarSize.sm;

  const AppAvatar.medium({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.placeholder,
    this.showBorder = false,
    this.borderColor,
  }) : size = AppAvatarSize.md;

  const AppAvatar.large({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.placeholder,
    this.showBorder = false,
    this.borderColor,
  }) : size = AppAvatarSize.lg;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();
    final displayInitials = _getInitials();
    final avatarBackgroundColor =
        backgroundColor ?? _getDefaultBackgroundColor();
    final avatarTextColor = textColor ?? AppColors.white;

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarBackgroundColor,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: AppDimensions.borderMedium,
              )
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _buildPlaceholder(displayInitials, avatarTextColor),
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(displayInitials, avatarTextColor),
              )
            : _buildPlaceholder(displayInitials, avatarTextColor),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildPlaceholder(String initials, Color textColor) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Center(
      child: Text(initials, style: _getTextStyle().copyWith(color: textColor)),
    );
  }

  double _getSize() {
    return switch (size) {
      AppAvatarSize.xs => AppDimensions.avatarXS,
      AppAvatarSize.sm => AppDimensions.avatarSM,
      AppAvatarSize.md => AppDimensions.avatarMD,
      AppAvatarSize.lg => AppDimensions.avatarLG,
      AppAvatarSize.xl => AppDimensions.avatarXL,
      AppAvatarSize.xxl => AppDimensions.avatarXXL,
      AppAvatarSize.xxxl => AppDimensions.avatarXXXL,
    };
  }

  TextStyle _getTextStyle() {
    return switch (size) {
      AppAvatarSize.xs => AppTypography.labelSmall,
      AppAvatarSize.sm => AppTypography.labelMedium,
      AppAvatarSize.md => AppTypography.labelLarge,
      AppAvatarSize.lg => AppTypography.bodyMedium,
      AppAvatarSize.xl => AppTypography.bodyLarge,
      AppAvatarSize.xxl => AppTypography.h6,
      AppAvatarSize.xxxl => AppTypography.h5,
    };
  }

  String _getInitials() {
    if (initials != null && initials!.isNotEmpty) {
      return initials!;
    }

    if (name != null && name!.isNotEmpty) {
      final words = name!.trim().split(' ');
      if (words.length >= 2) {
        return '${words.first[0]}${words.last[0]}'.toUpperCase();
      } else if (words.isNotEmpty) {
        return words.first.substring(0, 2).toUpperCase();
      }
    }

    return '??';
  }

  Color _getDefaultBackgroundColor() {
    // Generate a color based on initials or name for consistency
    final text = initials ?? name ?? '';
    final hash = text.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    return colors[hash.abs() % colors.length];
  }
}
