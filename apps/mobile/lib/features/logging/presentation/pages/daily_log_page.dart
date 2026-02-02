import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_log.dart';
import '../bloc/daily_log_bloc.dart';

/// Daily log page - shows activity logs with undo delete and full localization
class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
  }

  void _onCategoryChanged(String? category) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCategory = category);
    context.read<DailyLogBloc>().add(DailyLogCategoryFilterChanged(category));
  }

  void _deleteLog(DailyLog log) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Delete from bloc
    context.read<DailyLogBloc>().add(DailyLogDeleteRequested(log.id));

    // Show undo snackbar
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDeletedLabel(l10n),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkSurfaceHighest : AppColors.textSecondary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: _getUndoLabel(l10n),
          textColor: AppColors.primary,
          onPressed: () {
            // TODO: Implement undo - re-add the log
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  String _getDeletedLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kayıt silindi' : 'Entry deleted';
  String _getUndoLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Geri Al' : 'Undo';
  String _getTrackActivitiesLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Günlük aktivitelerinizi takip edin' : 'Track your daily activities';
  String _getNoEntriesLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Henüz kayıt yok' : 'No log entries yet';
  String _getStartTrackingLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Ana sayfadan aktivite ekleyebilirsiniz' : 'Add activities from the home page';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocBuilder<DailyLogBloc, DailyLogState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DailyLogBloc>().add(const DailyLogRefreshRequested());
            },
            child: CustomScrollView(
              slivers: [
                // Gradient header - theme aware
                SliverToBoxAdapter(
                  child: CurvedGradientHeader(
                    title: l10n.dailyLog,
                    subtitle: _getTrackActivitiesLabel(l10n),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0xFF3A3A45), const Color(0xFF2A2A32)]
                          : [AppColors.secondary, AppColors.secondaryDark],
                    ),
                  ),
                ),

                // Category filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: _buildCategoryFilter(l10n, isDark),
                  ),
                ),

                // Content based on state
                if (state is DailyLogLoading)
                  const SliverFillRemaining(
                    child: Center(child: AppLoadingIndicator()),
                  )
                else if (state is DailyLogError)
                  SliverFillRemaining(
                    child: _buildErrorView(l10n, isDark, state.message),
                  )
                else if (state is DailyLogLoaded)
                  if (state.logs.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyView(l10n, isDark),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LogEntryCard(
                              log: state.logs[index],
                              isDark: isDark,
                              onDelete: () => _deleteLog(state.logs[index]),
                            ),
                          ),
                          childCount: state.logs.length,
                        ),
                      ),
                    ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n, bool isDark) {
    final categories = [
      (null, l10n.all, null, null),
      ('meal', l10n.food, Icons.restaurant_rounded, AppColors.food),
      ('sleep', l10n.sleep, Icons.bedtime_rounded, AppColors.sleep),
      ('exercise', l10n.exercise, Icons.fitness_center_rounded, AppColors.exercise),
      ('medication', l10n.medication, Icons.medication_rounded, AppColors.medication),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return _FilterChip(
            label: cat.$2,
            icon: cat.$3,
            color: cat.$4,
            isSelected: _selectedCategory == cat.$1,
            isDark: isDark,
            onTap: () => _onCategoryChanged(cat.$1),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, bool isDark, String message) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? AppColors.errorDark : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.retry,
              variant: AppButtonVariant.outlined,
              onPressed: () {
                context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations l10n, bool isDark) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final accentColor = isDark ? AppColors.primaryDarkMode : AppColors.secondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.history_rounded, size: 40, color: accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              _getNoEntriesLabel(l10n),
              style: AppTypography.titleMedium.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              _getStartTrackingLabel(l10n),
              style: AppTypography.bodySmall.copyWith(color: textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    this.isSelected = false,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final chipColor = isDark ? (color ?? AppColors.primaryDarkMode) : (color ?? AppColors.primary);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: isDark ? 0.2 : 0.15)
                : surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? chipColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? chipColor : textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? chipColor : textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogEntryCard extends StatelessWidget {
  const _LogEntryCard({
    required this.log,
    required this.isDark,
    this.onDelete,
  });

  final DailyLog log;
  final bool isDark;
  final VoidCallback? onDelete;

  (Color, IconData, String) _getLogTypeInfo() {
    if (log.isMealLog) {
      return (AppColors.food, Icons.restaurant_rounded, log.mealType!.displayName);
    }
    if (log.isExerciseLog) {
      return (AppColors.exercise, Icons.fitness_center_rounded, log.exerciseType ?? 'Exercise');
    }
    if (log.isMedicationLog) {
      return (AppColors.medication, Icons.medication_rounded, 'Medication');
    }
    if (log.isSleepLog) {
      return (AppColors.sleep, Icons.bedtime_rounded, 'Sleep');
    }
    return (AppColors.secondary, Icons.note_alt_rounded, 'Note');
  }

  String _getDescription() {
    if (log.isMealLog) {
      return log.mealDescription ?? 'Meal logged';
    }
    if (log.isExerciseLog) {
      final duration = log.exerciseDurationMinutes;
      final intensity = log.exerciseIntensity?.displayName;
      return duration != null
          ? '$duration minutes${intensity != null ? ' - $intensity' : ''}'
          : 'Exercise logged';
    }
    if (log.isMedicationLog) {
      return log.medicationTaken == true
          ? 'Taken${log.medicationNotes != null ? ' - ${log.medicationNotes}' : ''}'
          : 'Not taken';
    }
    if (log.isSleepLog) {
      final hours = log.sleepHours;
      final quality = log.sleepQuality;
      return hours != null
          ? '${hours.toStringAsFixed(1)} hours${quality != null ? ' - Quality: $quality/5' : ''}'
          : 'Sleep logged';
    }
    return log.notes ?? 'Entry logged';
  }

  Map<String, String> _getMetadata() {
    final metadata = <String, String>{};

    if (log.isMealLog && log.carbsGrams != null) {
      metadata['Carbs'] = '${log.carbsGrams}g';
    }
    if (log.isExerciseLog && log.exerciseIntensity != null) {
      metadata['Intensity'] = log.exerciseIntensity!.displayName;
    }
    if (log.stressLevel != null) {
      metadata['Stress'] = '${log.stressLevel}/5';
    }

    return metadata;
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, title) = _getLogTypeInfo();
    final description = _getDescription();
    final metadata = _getMetadata();
    final timeFormatter = DateFormat('h:mm a');
    final time = log.createdAt != null
        ? timeFormatter.format(log.createdAt!)
        : timeFormatter.format(log.logDate);

    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final typeColor = isDark ? _getDarkColor(color) : color;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: borderColor, width: isDark ? 1 : 0),
        boxShadow: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(color: textPrimary),
                    ),
                    Text(
                      time,
                      style: AppTypography.labelSmall.copyWith(color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.notes != null && log.notes!.isNotEmpty && !log.isSleepLog) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.notes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: metadata.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTypography.labelSmall.copyWith(
                            color: typeColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Visible delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDark ? AppColors.errorDark : AppColors.error,
              size: 22,
            ),
            onPressed: onDelete,
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Color _getDarkColor(Color color) {
    if (color == AppColors.food) return AppColors.foodDark;
    if (color == AppColors.sleep) return AppColors.sleepDark;
    if (color == AppColors.exercise) return AppColors.exerciseDark;
    if (color == AppColors.medication) return AppColors.medicationDark;
    return AppColors.secondaryDarkMode;
  }
}
