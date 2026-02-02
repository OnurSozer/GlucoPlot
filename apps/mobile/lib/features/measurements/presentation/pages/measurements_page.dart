import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/history_category_card.dart';

/// History page - shows all logged activities organized by category
/// Premium design with full dark mode support
class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: CurvedGradientHeader(
              title: l10n.history,
              subtitle: l10n.historySubtitle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF3A3A45), const Color(0xFF2A2A32)] // Muted gray for dark mode
                    : [AppColors.secondary, AppColors.secondaryDark],
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: _buildFilterChips(l10n, isDark),
            ),
          ),

          // Content
          if (_selectedCategory == null)
            _buildCategoryGrid(l10n, isDark)
          else
            _buildCategoryDetail(l10n, isDark),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, bool isDark) {
    final categories = _getCategories(l10n, isDark);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.all,
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
            isDark: isDark,
          ),
          ...categories.map((cat) => _FilterChip(
                label: cat.label,
                icon: cat.icon,
                color: cat.color,
                isSelected: _selectedCategory == cat.id,
                onTap: () => setState(() => _selectedCategory = cat.id),
                isDark: isDark,
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(AppLocalizations l10n, bool isDark) {
    final categories = _getCategories(l10n, isDark);
    final logLabel = l10n.logs;

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cat = categories[index];
            return HistoryCategoryCard(
              icon: cat.icon,
              label: cat.label,
              color: cat.color,
              logCount: cat.count,
              logLabel: cat.count == 1 ? l10n.log : logLabel,
              onTap: () => setState(() => _selectedCategory = cat.id),
            );
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryDetail(AppLocalizations l10n, bool isDark) {
    final categories = _getCategories(l10n, isDark);
    final category = categories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => categories.first,
    );

    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    // For now, show empty state - this will be connected to actual data later
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.2),
                            blurRadius: 16,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  category.icon,
                  size: 40,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noLogsYet,
                style: AppTypography.titleMedium.copyWith(
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addLogsFromHome,
                style: AppTypography.bodySmall.copyWith(
                  color: textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_CategoryData> _getCategories(AppLocalizations l10n, bool isDark) {
    // Use brighter colors in dark mode
    return [
      _CategoryData(
        id: 'glucose',
        label: l10n.glucose,
        icon: Icons.bloodtype_rounded,
        color: isDark ? AppColors.glucoseDark : AppColors.glucose,
        count: 0,
      ),
      _CategoryData(
        id: 'food',
        label: l10n.food,
        icon: Icons.restaurant_rounded,
        color: isDark ? AppColors.foodDark : AppColors.food,
        count: 0,
      ),
      _CategoryData(
        id: 'medicine',
        label: l10n.medicine,
        icon: Icons.medication_rounded,
        color: isDark ? AppColors.medicationDark : AppColors.medication,
        count: 0,
      ),
      _CategoryData(
        id: 'toilet',
        label: l10n.toilet,
        icon: Icons.wc_rounded,
        color: isDark ? AppColors.secondaryDarkMode : AppColors.secondary,
        count: 0,
      ),
      _CategoryData(
        id: 'water',
        label: l10n.water,
        icon: Icons.water_drop_rounded,
        color: isDark ? AppColors.infoDark : AppColors.secondaryDark,
        count: 0,
      ),
      _CategoryData(
        id: 'alcohol',
        label: l10n.alcohol,
        icon: Icons.wine_bar_rounded,
        color: isDark ? AppColors.symptomDark : AppColors.symptom,
        count: 0,
      ),
      _CategoryData(
        id: 'sports',
        label: l10n.sports,
        icon: Icons.fitness_center_rounded,
        color: isDark ? AppColors.exerciseDark : AppColors.exercise,
        count: 0,
      ),
      _CategoryData(
        id: 'sleep',
        label: l10n.sleep,
        icon: Icons.bedtime_rounded,
        color: isDark ? AppColors.sleepDark : AppColors.sleep,
        count: 0,
      ),
      _CategoryData(
        id: 'stress',
        label: l10n.stress,
        icon: Icons.psychology_rounded,
        color: isDark ? AppColors.warningDark : AppColors.warning,
        count: 0,
      ),
      _CategoryData(
        id: 'blood_pressure',
        label: l10n.bloodPressure,
        icon: Icons.monitor_heart_rounded,
        color: isDark ? AppColors.bloodPressureDark : AppColors.bloodPressure,
        count: 0,
      ),
      _CategoryData(
        id: 'weight',
        label: l10n.weight,
        icon: Icons.monitor_weight_rounded,
        color: isDark ? AppColors.weightDark : AppColors.weight,
        count: 0,
      ),
    ];
  }
}

class _CategoryData {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final int count;

  const _CategoryData({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
  });
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    this.isSelected = false,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final bgColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? primaryColor).withValues(alpha: isDark ? 0.18 : 0.15)
                : bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? (color ?? primaryColor) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : textColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? (color ?? primaryColor)
                      : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
