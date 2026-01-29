import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Primary filled button
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.size = AppButtonSize.large,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final AppButtonSize size;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final child = _buildChild();

    Widget button;

    if (variant == AppButtonVariant.outlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    } else if (variant == AppButtonVariant.text) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: size == AppButtonSize.small ? 16 : 20,
        width: size == AppButtonSize.small ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? AppColors.textOnPrimary
                : AppColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size == AppButtonSize.small ? 18 : 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      AppButtonSize.large => const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
    };

    final textStyle = switch (size) {
      AppButtonSize.small => AppTypography.buttonMedium.copyWith(fontSize: 13),
      AppButtonSize.medium => AppTypography.buttonMedium,
      AppButtonSize.large => AppTypography.buttonLarge,
    };

    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => AppColors.secondary,
      AppButtonVariant.outlined => Colors.transparent,
      AppButtonVariant.text => Colors.transparent,
      AppButtonVariant.danger => AppColors.error,
    };

    final foregroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.textOnPrimary,
      AppButtonVariant.secondary => AppColors.textOnPrimary,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.text => AppColors.primary,
      AppButtonVariant.danger => AppColors.textOnPrimary,
    };

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      textStyle: textStyle,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}

enum AppButtonSize { small, medium, large }

enum AppButtonVariant { primary, secondary, outlined, text, danger }
