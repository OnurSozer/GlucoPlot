import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Gradient header widget inspired by Apple Health
/// Creates a warm peach/coral gradient background
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.height,
    this.gradient,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final double? height;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.headerGradient,
        borderRadius: borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
      ),
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}

/// Full-page gradient background (like welcome screen)
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.headerGradient,
      ),
      child: child,
    );
  }
}

/// Header with gradient and curved card below
class CurvedGradientHeader extends StatelessWidget {
  const CurvedGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.gradient,
    this.height = 180,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ?? AppColors.headerGradient,
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trailing case final trailingWidget?)
                    Align(
                      alignment: Alignment.centerRight,
                      child: trailingWidget,
                    ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Curved overlay at bottom - theme aware
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
