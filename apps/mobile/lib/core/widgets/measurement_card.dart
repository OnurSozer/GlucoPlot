import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Health measurement card inspired by Apple Health
/// Shows a metric with value, unit, mini chart, and optional trend
class MeasurementCard extends StatelessWidget {
  const MeasurementCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.icon,
    this.subtitle,
    this.trend,
    this.miniChart,
    this.onTap,
    this.backgroundColor,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData? icon;
  final String? subtitle;
  final MeasurementTrend? trend;
  final Widget? miniChart;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and title
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(color: color),
                ),
                const Spacer(),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.labelSmall,
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Value row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: AppTypography.measurementValueMedium,
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              unit,
                              style: AppTypography.measurementUnit,
                            ),
                          ),
                        ],
                      ),
                      if (trend != null) ...[
                        const SizedBox(height: 4),
                        _buildTrendIndicator(),
                      ],
                    ],
                  ),
                ),
                if (miniChart != null)
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: miniChart,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final trendColor = switch (trend!) {
      MeasurementTrend.up => AppColors.warning,
      MeasurementTrend.down => AppColors.info,
      MeasurementTrend.stable => AppColors.success,
      MeasurementTrend.critical => AppColors.error,
    };

    final trendIcon = switch (trend!) {
      MeasurementTrend.up => Icons.trending_up_rounded,
      MeasurementTrend.down => Icons.trending_down_rounded,
      MeasurementTrend.stable => Icons.trending_flat_rounded,
      MeasurementTrend.critical => Icons.warning_rounded,
    };

    final trendText = switch (trend!) {
      MeasurementTrend.up => 'Rising',
      MeasurementTrend.down => 'Falling',
      MeasurementTrend.stable => 'Stable',
      MeasurementTrend.critical => 'Attention needed',
    };

    return Row(
      children: [
        Icon(trendIcon, color: trendColor, size: 16),
        const SizedBox(width: 4),
        Text(
          trendText,
          style: AppTypography.labelSmall.copyWith(color: trendColor),
        ),
      ],
    );
  }
}

enum MeasurementTrend { up, down, stable, critical }

/// Compact measurement card for dashboard grid
class CompactMeasurementCard extends StatelessWidget {
  const CompactMeasurementCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelSmall.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
