import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// A card widget representing a category in the history grid
/// Premium design with full dark mode support
class HistoryCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int logCount;
  final String logLabel;
  final VoidCallback onTap;

  const HistoryCategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.logCount,
    required this.logLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final iconBgAlpha = isDark ? 0.18 : 0.15;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isDark ? 1 : 0),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: iconBgAlpha),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$logCount $logLabel',
              style: AppTypography.labelSmall.copyWith(
                color: textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
