import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../measurements/domain/entities/measurement.dart';
import '../../../measurements/domain/repositories/measurement_repository.dart';
import '../../domain/entities/daily_log.dart';
import '../bloc/daily_log_bloc.dart';
import 'add_log_entry_page.dart';

/// Daily log page - shows activity logs with undo delete and full localization
class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  late DateTime _selectedDate;
  List<Measurement> _measurements = [];
  bool _isLoadingMeasurements = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Load logs and measurements for today
    context.read<DailyLogBloc>().add(DailyLogLoadRequested(date: _selectedDate));
    _loadMeasurements(_selectedDate);
  }

  Future<void> _loadMeasurements(DateTime date) async {
    setState(() => _isLoadingMeasurements = true);

    final repository = sl<MeasurementRepository>();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await repository.getMeasurements(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    if (mounted) {
      setState(() {
        _isLoadingMeasurements = false;
        if (result is MeasurementSuccess<List<Measurement>>) {
          // Filter to only glucose and blood_pressure
          _measurements = result.data
              .where((m) => m.type == MeasurementType.glucose || m.type == MeasurementType.bloodPressure)
              .toList();
        } else {
          _measurements = [];
        }
      });
    }
  }

  /// Build a sorted list of unified items (logs + measurements) by time, newest first
  List<_UnifiedItem> _buildSortedItems(List<DailyLog> logs) {
    final items = <_UnifiedItem>[];

    // Add measurements
    for (final m in _measurements) {
      items.add(_UnifiedItem.measurement(m, m.measuredAt));
    }

    // Add logs
    for (final log in logs) {
      final time = log.loggedAt ?? log.createdAt ?? log.logDate;
      items.add(_UnifiedItem.log(log, time));
    }

    // Sort by time, newest first
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return items;
  }

  void _onDateChanged(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = date);
    context.read<DailyLogBloc>().add(DailyLogDateChanged(date));
    _loadMeasurements(date);
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      _onDateChanged(picked);
    }
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

  Future<void> _deleteMeasurement(Measurement measurement) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.localeName == 'tr' ? 'Kaydı Sil' : 'Delete Record',
        ),
        content: Text(
          l10n.localeName == 'tr'
              ? 'Bu ölçümü silmek istediğinizden emin misiniz?'
              : 'Are you sure you want to delete this measurement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.errorDark : AppColors.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Delete from repository
    final repository = sl<MeasurementRepository>();
    final result = await repository.deleteMeasurement(measurement.id);

    if (!mounted) return;

    if (result is MeasurementSuccess) {
      // Reload measurements
      _loadMeasurements(_selectedDate);

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
                  l10n.localeName == 'tr' ? 'Ölçüm silindi' : 'Measurement deleted',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: isDark ? AppColors.darkSurfaceHighest : AppColors.textSecondary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _getDeletedLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kayıt silindi' : 'Entry deleted';
  String _getUndoLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Geri Al' : 'Undo';
  String _getTrackActivitiesLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Günlük aktivitelerinizi takip edin' : 'Track your daily activities';
  String _getNoEntriesLabel(AppLocalizations l10n) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    if (isToday) {
      return l10n.localeName == 'tr' ? 'Bugün kayıt yok' : 'No entries today';
    }
    return l10n.localeName == 'tr' ? 'Bu tarihte kayıt yok' : 'No entries for this date';
  }

  String _getStartTrackingLabel(AppLocalizations l10n) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    if (isToday) {
      return l10n.localeName == 'tr' ? 'Ana sayfadan aktivite ekleyebilirsiniz' : 'Add activities from the home page';
    }
    return l10n.localeName == 'tr' ? 'Başka bir tarih seçin' : 'Select a different date';
  }

  void _editLog(DailyLog log) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddLogEntryPage(existingLog: log),
      ),
    );
  }

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

                // Date picker
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: _buildDatePicker(l10n, isDark),
                  ),
                ),

                // Content based on state
                if (state is DailyLogLoading && _isLoadingMeasurements)
                  const SliverFillRemaining(
                    child: Center(child: AppLoadingIndicator()),
                  )
                else if (state is DailyLogError)
                  SliverFillRemaining(
                    child: _buildErrorView(l10n, isDark, state.message),
                  )
                else if (state is DailyLogLoaded)
                  if (state.logs.isEmpty && _measurements.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyView(l10n, isDark),
                    )
                  else
                    // Combined list sorted by time (newest first)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final items = _buildSortedItems(state.logs);
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: item.isMeasurement
                                  ? _MeasurementCard(
                                      measurement: item.measurement!,
                                      isDark: isDark,
                                      locale: l10n.localeName,
                                      onDelete: () => _deleteMeasurement(item.measurement!),
                                    )
                                  : _LogEntryCard(
                                      log: item.log!,
                                      isDark: isDark,
                                      onEdit: () => _editLog(item.log!),
                                      onDelete: () => _deleteLog(item.log!),
                                    ),
                            );
                          },
                          childCount: _buildSortedItems(state.logs).length,
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

  Widget _buildDatePicker(AppLocalizations l10n, bool isDark) {
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy', l10n.localeName);
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      children: [
        // Previous day button
        IconButton(
          onPressed: () => _onDateChanged(_selectedDate.subtract(const Duration(days: 1))),
          icon: Icon(
            Icons.chevron_left_rounded,
            color: textSecondary,
          ),
          visualDensity: VisualDensity.compact,
        ),

        // Date display - tap to open picker
        Expanded(
          child: GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      if (isToday)
                        Text(
                          l10n.localeName == 'tr' ? 'Bugün' : 'Today',
                          style: AppTypography.labelMedium.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        dateFormatter.format(_selectedDate),
                        style: AppTypography.bodySmall.copyWith(
                          color: isToday ? textSecondary : textPrimary,
                          fontWeight: isToday ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Next day button (disabled if today)
        IconButton(
          onPressed: isToday
              ? null
              : () => _onDateChanged(_selectedDate.add(const Duration(days: 1))),
          icon: Icon(
            Icons.chevron_right_rounded,
            color: isToday ? textSecondary.withValues(alpha: 0.3) : textSecondary,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
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
                context.read<DailyLogBloc>().add(DailyLogLoadRequested(date: _selectedDate));
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

class _LogEntryCard extends StatelessWidget {
  const _LogEntryCard({
    required this.log,
    required this.isDark,
    this.onEdit,
    this.onDelete,
  });

  final DailyLog log;
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  (Color, IconData, String) _getLogTypeInfo() {
    switch (log.logType) {
      case LogType.food:
        return (AppColors.food, Icons.restaurant_rounded, log.title);
      case LogType.exercise:
        return (AppColors.exercise, Icons.fitness_center_rounded, log.title);
      case LogType.medication:
        return (AppColors.medication, Icons.medication_rounded, log.title);
      case LogType.sleep:
        return (AppColors.sleep, Icons.bedtime_rounded, log.title);
      case LogType.symptom:
        return (AppColors.warning, Icons.psychology_rounded, log.title);
      case LogType.note:
        // Check metadata for specific type (water, alcohol, toilet)
        final subType = log.metadata?['type'] as String?;
        if (subType == 'water') {
          return (AppColors.secondaryDark, Icons.water_drop_rounded, log.title);
        } else if (subType == 'alcohol') {
          return (AppColors.symptom, Icons.wine_bar_rounded, log.title);
        } else if (subType == 'toilet') {
          return (AppColors.secondary, Icons.wc_rounded, log.title);
        }
        return (AppColors.secondary, Icons.note_alt_rounded, log.title);
    }
  }

  String _getDescription() {
    final parts = <String>[];

    // Add user description if available
    if (log.description != null && log.description!.isNotEmpty) {
      parts.add(log.description!);
    }

    // Add metadata based on log type
    switch (log.logType) {
      case LogType.food:
        final calories = log.calories;
        final carbs = log.carbsGrams;
        if (carbs != null) parts.add('${carbs}g carbs');
        if (calories != null) parts.add('$calories cal');
        if (parts.isEmpty) parts.add('Meal logged');

      case LogType.exercise:
        final duration = log.exerciseDuration;
        final intensity = log.exerciseIntensity?.displayName;
        if (duration != null) parts.add('$duration min');
        if (intensity != null) parts.add(intensity);
        if (parts.isEmpty) parts.add('Exercise logged');

      case LogType.sleep:
        final hours = log.sleepHours;
        final quality = log.sleepQuality;
        if (hours != null) parts.add('${hours.toStringAsFixed(1)} hours');
        if (quality != null) parts.add('Quality: $quality');
        if (parts.isEmpty) parts.add('Sleep logged');

      case LogType.medication:
        final dosage = log.metadata?['dosage'] as String?;
        if (dosage != null) parts.add(dosage);
        if (parts.isEmpty) parts.add('Medication taken');

      case LogType.symptom:
        final stressLevel = log.stressLevel;
        if (stressLevel != null) parts.add('Stress: $stressLevel/10');
        if (parts.isEmpty) parts.add('Symptom logged');

      case LogType.note:
        final subType = log.metadata?['type'] as String?;
        if (subType == 'water') {
          final amount = log.amountMl;
          if (amount != null) parts.add('$amount ml');
          if (parts.isEmpty) parts.add('Water logged');
        } else if (subType == 'alcohol') {
          final amount = log.amountMl;
          final type = log.metadata?['alcohol_type'] as String?;
          if (amount != null) parts.add('$amount ml');
          if (type != null) parts.add(type);
          if (parts.isEmpty) parts.add('Alcohol logged');
        } else if (subType == 'toilet') {
          final toiletType = log.metadata?['toilet_type'] as String?;
          if (toiletType != null) parts.add(toiletType);
          if (parts.isEmpty) parts.add('Bathroom visit');
        } else {
          if (parts.isEmpty) parts.add('Note logged');
        }
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, title) = _getLogTypeInfo();
    final description = _getDescription();
    final timeFormatter = DateFormat('HH:mm');
    final time = log.loggedAt != null
        ? timeFormatter.format(log.loggedAt!)
        : (log.createdAt != null
            ? timeFormatter.format(log.createdAt!)
            : timeFormatter.format(log.logDate));

    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
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
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '$description · $time',
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action buttons row (horizontal)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              if (onEdit != null)
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? AppColors.primaryDarkMode : AppColors.primary,
                    size: 20,
                  ),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark ? AppColors.errorDark : AppColors.error,
                  size: 20,
                ),
                onPressed: onDelete,
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
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

/// Card to display a measurement (glucose or blood pressure)
/// Styled to match _LogEntryCard for consistency
class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.measurement,
    required this.isDark,
    required this.locale,
    required this.onDelete,
  });

  final Measurement measurement;
  final bool isDark;
  final String locale;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isGlucose = measurement.type == MeasurementType.glucose;
    final isBloodPressure = measurement.type == MeasurementType.bloodPressure;

    // Colors
    final color = isGlucose
        ? (isDark ? AppColors.glucoseDark : AppColors.glucose)
        : (isDark ? AppColors.bloodPressureDark : AppColors.bloodPressure);

    // Icon
    final icon = isGlucose ? Icons.bloodtype_rounded : Icons.monitor_heart_rounded;

    // Title
    final title = isGlucose
        ? (locale == 'tr' ? 'Kan Şekeri' : 'Blood Glucose')
        : (locale == 'tr' ? 'Tansiyon' : 'Blood Pressure');

    // Value display
    String valueDisplay;
    if (isBloodPressure && measurement.secondaryValue != null) {
      valueDisplay = '${measurement.value.toInt()}/${measurement.secondaryValue!.toInt()}';
    } else {
      valueDisplay = '${measurement.value.toInt()}';
    }

    // Unit
    final unit = measurement.displayUnit;

    // Time - use 24-hour format for clarity
    final timeFormatter = DateFormat('HH:mm');
    final time = timeFormatter.format(measurement.measuredAt);

    // Meal timing for glucose
    final mealTiming = measurement.mealTiming;

    // Build description like log cards
    final descriptionParts = <String>[];
    descriptionParts.add('$valueDisplay $unit');
    if (mealTiming != null) {
      descriptionParts.add(_getMealTimingLabel(mealTiming));
    }
    final description = descriptionParts.join(' · ');

    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

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
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '$description · $time',
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Delete button
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

  String _getMealTimingLabel(MealTiming timing) {
    switch (timing) {
      case MealTiming.fasting:
        return locale == 'tr' ? 'Açlık' : 'Fasting';
      case MealTiming.postMeal:
        return locale == 'tr' ? 'Tokluk' : 'After Meal';
      case MealTiming.other:
        return locale == 'tr' ? 'Diğer' : 'Other';
    }
  }
}

/// Unified item for combining logs and measurements in a single sorted list
class _UnifiedItem {
  final DailyLog? log;
  final Measurement? measurement;
  final DateTime timestamp;

  const _UnifiedItem._({
    this.log,
    this.measurement,
    required this.timestamp,
  });

  factory _UnifiedItem.log(DailyLog log, DateTime timestamp) {
    return _UnifiedItem._(log: log, timestamp: timestamp);
  }

  factory _UnifiedItem.measurement(Measurement measurement, DateTime timestamp) {
    return _UnifiedItem._(measurement: measurement, timestamp: timestamp);
  }

  bool get isMeasurement => measurement != null;
  bool get isLog => log != null;
}
