import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/daily_log.dart';
import '../bloc/daily_log_bloc.dart';

/// Daily log page - shows activity logs
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
    setState(() => _selectedCategory = category);
    context.read<DailyLogBloc>().add(DailyLogCategoryFilterChanged(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DailyLogBloc, DailyLogState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DailyLogBloc>().add(const DailyLogRefreshRequested());
            },
            child: CustomScrollView(
              slivers: [
                // Gradient header
                SliverToBoxAdapter(
                  child: CurvedGradientHeader(
                    title: AppStrings.dailyLog,
                    subtitle: 'Track your daily activities',
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.secondary,
                        AppColors.secondaryDark,
                      ],
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
                    child: _buildCategoryFilter(),
                  ),
                ),

                // Content based on state
                if (state is DailyLogLoading)
                  const SliverFillRemaining(
                    child: Center(child: AppLoadingIndicator()),
                  )
                else if (state is DailyLogError)
                  SliverFillRemaining(
                    child: _buildErrorView(state.message),
                  )
                else if (state is DailyLogLoaded)
                  if (state.logs.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyView(),
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
                              onDelete: () {
                                context.read<DailyLogBloc>().add(
                                  DailyLogDeleteRequested(state.logs[index].id),
                                );
                              },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/log/add'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedCategory == null,
            onTap: () => _onCategoryChanged(null),
          ),
          _FilterChip(
            label: AppStrings.food,
            icon: Icons.restaurant_rounded,
            color: AppColors.food,
            isSelected: _selectedCategory == 'meal',
            onTap: () => _onCategoryChanged('meal'),
          ),
          _FilterChip(
            label: AppStrings.sleep,
            icon: Icons.bedtime_rounded,
            color: AppColors.sleep,
            isSelected: _selectedCategory == 'sleep',
            onTap: () => _onCategoryChanged('sleep'),
          ),
          _FilterChip(
            label: AppStrings.exercise,
            icon: Icons.fitness_center_rounded,
            color: AppColors.exercise,
            isSelected: _selectedCategory == 'exercise',
            onTap: () => _onCategoryChanged('exercise'),
          ),
          _FilterChip(
            label: AppStrings.medication,
            icon: Icons.medication_rounded,
            color: AppColors.medication,
            isSelected: _selectedCategory == 'medication',
            onTap: () => _onCategoryChanged('medication'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
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

  Widget _buildEmptyView() {
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
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.edit_note, size: 40, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              'No log entries yet',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your meals, exercise, and more',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Add First Entry',
              onPressed: () => context.push('/log/add'),
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
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppColors.primary).withOpacity(0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? (color ?? AppColors.primary) : Colors.transparent,
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
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? (color ?? AppColors.primary)
                      : AppColors.textSecondary,
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
    this.onDelete,
  });

  final DailyLog log;
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

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTypography.titleMedium),
                      Text(time, style: AppTypography.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (log.notes != null && !log.notes!.isEmpty && !log.isSleepLog) ...[
                    const SizedBox(height: 4),
                    Text(
                      log.notes!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
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
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: AppTypography.labelSmall.copyWith(
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
