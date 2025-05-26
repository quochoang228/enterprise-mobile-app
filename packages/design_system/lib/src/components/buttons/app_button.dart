import 'package:flutter/material.dart';
import '../../../design_system.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_typography.dart';

enum AppButtonSize { small, medium, large }

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {

  const AppButton({
    required this.text, super.key,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
  });

  const AppButton.primary({
    required this.text, super.key,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    required this.text, super.key,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    required this.text, super.key,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    required this.text, super.key,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.text;
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getHeight();
    // final textStyle = _getTextStyle();
    final buttonStyle = _getButtonStyle(context);

    var child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(context),
              ),
            ),
          )
        : _buildButtonContent();

    if (icon != null) {
      child = icon!;
    }

    final button = SizedBox(
      height: buttonHeight,
      width: isFullWidth ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.primary ||
        AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
        AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
        AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      },
    );

    return button;
  }

  Widget _buildButtonContent() {
    final children = <Widget>[];

    if (leadingIcon != null) {
      children..add(leadingIcon!)
      ..add(const SizedBox(width: 8));
    }

    children.add(Text(text));

    if (trailingIcon != null) {
      children..add(const SizedBox(width: 8))
      ..add(trailingIcon!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getHeight() => switch (size) {
      AppButtonSize.small => AppDimensions.buttonHeightSM,
      AppButtonSize.medium => AppDimensions.buttonHeightMD,
      AppButtonSize.large => AppDimensions.buttonHeightLG,
    };

  TextStyle _getTextStyle() => switch (size) {
      AppButtonSize.small => AppTypography.buttonSmall,
      AppButtonSize.medium => AppTypography.buttonMedium,
      AppButtonSize.large => AppTypography.buttonLarge,
    };

  ButtonStyle _getButtonStyle(BuildContext context) {
    // final theme = Theme.of(context);
    final textStyle = _getTextStyle();

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        textStyle: textStyle,
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        textStyle: textStyle,
      ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        textStyle: textStyle,
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        textStyle: textStyle,
      ),
    };
  }

  Color _getLoadingColor(BuildContext context) => switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.secondary => AppColors.white,
      AppButtonVariant.outline || AppButtonVariant.text => AppColors.primary,
    };
}
