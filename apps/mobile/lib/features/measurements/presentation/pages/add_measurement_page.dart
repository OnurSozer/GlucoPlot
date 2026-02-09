import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/measurement.dart' as domain;
import '../bloc/measurement_bloc.dart';

/// Add measurement page
class AddMeasurementPage extends StatefulWidget {
  final String? initialType;

  const AddMeasurementPage({
    super.key,
    this.initialType,
  });

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final _valueController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _notesController = TextEditingController();

  late _MeasurementTypeUI _selectedType;
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;
  bool _showTypeSelector = true;

  @override
  void initState() {
    super.initState();
    // Set initial type based on parameter
    if (widget.initialType != null) {
      _selectedType = _parseInitialType(widget.initialType!);
      _showTypeSelector = false;
    } else {
      _selectedType = _MeasurementTypeUI.glucose;
    }
  }

  _MeasurementTypeUI _parseInitialType(String type) {
    switch (type.toLowerCase()) {
      case 'glucose':
        return _MeasurementTypeUI.glucose;
      case 'bloodpressure':
      case 'blood_pressure':
        return _MeasurementTypeUI.bloodPressure;
      case 'weight':
        return _MeasurementTypeUI.weight;
      default:
        return _MeasurementTypeUI.glucose;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _secondaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectQuickTime(int minutesAgo) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDateTime = DateTime.now().subtract(Duration(minutes: minutesAgo));
    });
  }

  Future<void> _selectCustomDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterValue)),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterValidNumber)),
      );
      return;
    }

    double? secondaryValue;
    if (_selectedType == _MeasurementTypeUI.bloodPressure) {
      secondaryValue = double.tryParse(_secondaryController.text);
      if (secondaryValue == null && _secondaryController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseEnterValidDiastolic)),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    // Dispatch add event to BLoC
    context.read<MeasurementBloc>().add(MeasurementAddRequested(
      type: _selectedType.toDomain,
      value: value,
      secondaryValue: secondaryValue,
      unit: _selectedType.unit,
      measuredAt: _selectedDateTime,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    ));

    // Wait a bit for the operation
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.measurementSaved),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.addMeasurement),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const AppLoadingIndicator(size: 24, color: Colors.white)
                  : Text(
                      l10n.save,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Measurement type selector (only shown when no initial type provided)
            if (_showTypeSelector) ...[
              Text(
                l10n.selectType,
                style: AppTypography.labelMedium.copyWith(
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(l10n),
              const SizedBox(height: 32),
            ],

            // Value input
            MeasurementInputField(
              controller: _valueController,
              label: _getTypeLabel(l10n, _selectedType),
              unit: _selectedType.unit,
              hint: _selectedType.hint,
              autofocus: true,
            ),

            // Secondary value for blood pressure
            if (_selectedType == _MeasurementTypeUI.bloodPressure) ...[
              const SizedBox(height: 16),
              MeasurementInputField(
                controller: _secondaryController,
                label: l10n.diastolic,
                unit: 'mmHg',
                hint: '80',
              ),
            ],

            const SizedBox(height: 24),

            // Date/time selector
            Text(
              l10n.whenMeasured,
              style: AppTypography.labelMedium.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateTimeSelector(l10n),

            const SizedBox(height: 24),

            // Notes
            AppTextField(
              controller: _notesController,
              label: l10n.notes,
              hint: l10n.notesHint,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(AppLocalizations l10n, _MeasurementTypeUI type) {
    switch (type) {
      case _MeasurementTypeUI.glucose:
        return l10n.bloodGlucose;
      case _MeasurementTypeUI.bloodPressure:
        return l10n.systolic;
      case _MeasurementTypeUI.weight:
        return l10n.weight;
    }
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final surfaceVariant = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _MeasurementTypeUI.values.map((type) {
        final isSelected = type == _selectedType;
        final label = _getTypeSelectorLabel(l10n, type);
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? type.color.withOpacity(0.15) : surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? type.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  color: isSelected ? type.color : textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? type.color : textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTypeSelectorLabel(AppLocalizations l10n, _MeasurementTypeUI type) {
    switch (type) {
      case _MeasurementTypeUI.glucose:
        return l10n.glucose;
      case _MeasurementTypeUI.bloodPressure:
        return l10n.bloodPressure;
      case _MeasurementTypeUI.weight:
        return l10n.weight;
    }
  }

  Widget _buildDateTimeSelector(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;

    final now = DateTime.now();
    final isNow = _selectedDateTime.difference(now).inMinutes.abs() < 2;
    final is15MinAgo = (_selectedDateTime.difference(now).inMinutes + 15).abs() < 2;
    final is30MinAgo = (_selectedDateTime.difference(now).inMinutes + 30).abs() < 2;
    final is1HourAgo = (_selectedDateTime.difference(now).inMinutes + 60).abs() < 2;
    final isCustom = !isNow && !is15MinAgo && !is30MinAgo && !is1HourAgo;

    // Localized labels
    final nowLabel = l10n.localeName == 'tr' ? 'Şimdi' : 'Now';
    final min15Label = l10n.localeName == 'tr' ? '15 dk önce' : '15 min ago';
    final min30Label = l10n.localeName == 'tr' ? '30 dk önce' : '30 min ago';
    final hour1Label = l10n.localeName == 'tr' ? '1 saat önce' : '1 hour ago';
    final customLabel = l10n.localeName == 'tr' ? 'Özel' : 'Custom';

    final quickOptions = [
      (nowLabel, 0, isNow),
      (min15Label, 15, is15MinAgo),
      (min30Label, 30, is30MinAgo),
      (hour1Label, 60, is1HourAgo),
    ];

    return Column(
      children: [
        // Quick time buttons
        Row(
          children: quickOptions.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _selectQuickTime(option.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: option.$3
                          ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.15)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: option.$3 ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      option.$1,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: option.$3 ? primaryColor : textSecondary,
                        fontWeight: option.$3 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Custom time button
        GestureDetector(
          onTap: _selectCustomDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCustom
                  ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.1)
                  : cardBg,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isCustom ? primaryColor : borderColor,
                width: isCustom ? 2 : (isDark ? 1 : 0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: isCustom ? primaryColor : textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        '${_formatDate(_selectedDateTime, l10n)} - ${_formatTime(_selectedDateTime, l10n)}',
                        style: AppTypography.bodyLarge.copyWith(
                          color: textPrimary,
                          fontWeight: isCustom ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return l10n.today;
    }
    // Use locale-aware date format
    final locale = l10n.localeName;
    if (locale == 'tr') {
      return '${date.day}.${date.month}.${date.year}';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date, AppLocalizations l10n) {
    // Use 24-hour format for Turkish locale
    final locale = l10n.localeName;
    if (locale == 'tr') {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

/// UI-specific measurement type enum with display properties
/// Only glucose, blood pressure, and weight are supported in the mobile app
enum _MeasurementTypeUI {
  glucose(
    label: 'Blood Glucose',
    unit: 'mg/dL',
    hint: '100',
    icon: Icons.bloodtype_rounded,
    color: AppColors.glucose,
  ),
  bloodPressure(
    label: 'Systolic',
    unit: 'mmHg',
    hint: '120',
    icon: Icons.monitor_heart_rounded,
    color: AppColors.bloodPressure,
  ),
  weight(
    label: 'Weight',
    unit: 'kg',
    hint: '70',
    icon: Icons.monitor_weight_rounded,
    color: AppColors.weight,
  );

  const _MeasurementTypeUI({
    required this.label,
    required this.unit,
    required this.hint,
    required this.icon,
    required this.color,
  });

  final String label;
  final String unit;
  final String hint;
  final IconData icon;
  final Color color;

  /// Convert to domain MeasurementType for database operations
  domain.MeasurementType get toDomain {
    switch (this) {
      case _MeasurementTypeUI.glucose:
        return domain.MeasurementType.glucose;
      case _MeasurementTypeUI.bloodPressure:
        return domain.MeasurementType.bloodPressure;
      case _MeasurementTypeUI.weight:
        return domain.MeasurementType.weight;
    }
  }
}
