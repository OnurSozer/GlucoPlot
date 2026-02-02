import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/activity_tile.dart';
import '../widgets/glucose_card.dart';

/// Patient dashboard - main home screen with Design 1 layout
/// Premium design with full dark mode support
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshRequested());
              },
              color: isDark ? AppColors.primaryDarkMode : AppColors.primary,
              backgroundColor: isDark ? AppColors.darkCardBackground : AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context, l10n, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Glucose Measurement Card
                      GlucoseCard(
                        onTap: () => context.push('/measurements/add', extra: 'glucose'),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Activity Tiles Grid
                      _buildActivityGrid(context, l10n, isDark),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App name and greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getGreeting(l10n),
              style: AppTypography.bodyMedium.copyWith(
                color: textSecondary,
              ),
            ),
          ],
        ),
        // Actions
        Row(
          children: [
            // Notification bell
            _buildIconButton(
              context: context,
              icon: Icons.notifications_outlined,
              onTap: () {
                // TODO: Show notifications
              },
              badgeCount: 0,
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Profile avatar
            GestureDetector(
              onTap: () => context.go('/settings'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.primaryDarkMode, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.primaryDarkMode.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
    required bool isDark,
  }) {
    final bgColor = isDark ? AppColors.darkCardBackground : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorderSubtle : AppColors.border;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.errorDark : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityGrid(BuildContext context, AppLocalizations l10n, bool isDark) {
    // Use brighter colors in dark mode for better visibility
    final activities = [
      ActivityTileData(
        icon: Icons.restaurant_rounded,
        label: l10n.food,
        color: isDark ? AppColors.foodDark : AppColors.food,
        onTap: () => _logActivity(context, 'food'),
      ),
      ActivityTileData(
        icon: Icons.medication_rounded,
        label: l10n.medicine,
        color: isDark ? AppColors.medicationDark : AppColors.medication,
        onTap: () => _logActivity(context, 'medication'),
      ),
      ActivityTileData(
        icon: Icons.wc_rounded,
        label: l10n.toilet,
        color: isDark ? AppColors.secondaryDarkMode : AppColors.secondary,
        onTap: () => _logActivity(context, 'toilet'),
      ),
      ActivityTileData(
        icon: Icons.water_drop_rounded,
        label: l10n.water,
        color: isDark ? AppColors.infoDark : AppColors.secondaryDark,
        onTap: () => _logActivity(context, 'water'),
      ),
      ActivityTileData(
        icon: Icons.wine_bar_rounded,
        label: l10n.alcohol,
        color: isDark ? AppColors.symptomDark : AppColors.symptom,
        onTap: () => _logActivity(context, 'alcohol'),
      ),
      ActivityTileData(
        icon: Icons.fitness_center_rounded,
        label: l10n.sports,
        color: isDark ? AppColors.exerciseDark : AppColors.exercise,
        onTap: () => _logActivity(context, 'exercise'),
      ),
      ActivityTileData(
        icon: Icons.bedtime_rounded,
        label: l10n.sleep,
        color: isDark ? AppColors.sleepDark : AppColors.sleep,
        onTap: () => _logActivity(context, 'sleep'),
      ),
      ActivityTileData(
        icon: Icons.psychology_rounded,
        label: l10n.stress,
        color: isDark ? AppColors.warningDark : AppColors.warning,
        onTap: () => _logActivity(context, 'stress'),
      ),
      ActivityTileData(
        icon: Icons.favorite_rounded,
        label: l10n.bloodPressure,
        color: isDark ? AppColors.bloodPressureDark : AppColors.bloodPressure,
        onTap: () => context.push('/measurements/add', extra: 'bloodPressure'),
      ),
      ActivityTileData(
        icon: Icons.monitor_weight_rounded,
        label: l10n.weight,
        color: isDark ? AppColors.weightDark : AppColors.weight,
        onTap: () => context.push('/measurements/add', extra: 'weight'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityTile(
          icon: activity.icon,
          label: activity.label,
          color: activity.color,
          onTap: activity.onTap,
        );
      },
    );
  }

  void _logActivity(BuildContext context, String type) {
    context.push('/log/add', extra: type);
  }
}

/// Data class for activity tile
class ActivityTileData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  ActivityTileData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
