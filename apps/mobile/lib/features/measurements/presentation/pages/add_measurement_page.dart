import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
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

  Future<void> _selectDateTime() async {
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
    if (_valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    double? secondaryValue;
    if (_selectedType == _MeasurementTypeUI.bloodPressure) {
      secondaryValue = double.tryParse(_secondaryController.text);
      if (secondaryValue == null && _secondaryController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid diastolic value')),
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
        const SnackBar(
          content: Text(AppStrings.measurementSaved),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.addMeasurement),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const AppLoadingIndicator(size: 20)
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Measurement type selector (only shown when no initial type provided)
            if (_showTypeSelector) ...[
              Text(
                AppStrings.selectType,
                style: AppTypography.labelMedium.copyWith(
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 32),
            ],

            // Value input
            MeasurementInputField(
              controller: _valueController,
              label: _selectedType.label,
              unit: _selectedType.unit,
              hint: _selectedType.hint,
              autofocus: true,
            ),

            // Secondary value for blood pressure
            if (_selectedType == _MeasurementTypeUI.bloodPressure) ...[
              const SizedBox(height: 16),
              MeasurementInputField(
                controller: _secondaryController,
                label: 'Diastolic',
                unit: 'mmHg',
                hint: '80',
              ),
            ],

            const SizedBox(height: 24),

            // Date/time selector
            Text(
              'When was this measured?',
              style: AppTypography.labelMedium.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateTimeSelector(),

            const SizedBox(height: 24),

            // Notes
            AppTextField(
              controller: _notesController,
              label: AppStrings.notes,
              hint: 'Add any notes about this measurement...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final surfaceVariant = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _MeasurementTypeUI.values.map((type) {
        final isSelected = type == _selectedType;
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
                  type.label,
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

  Widget _buildDateTimeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final surfaceVariant = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return GestureDetector(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(_selectedDateTime),
                    style: AppTypography.bodyLarge.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    _formatTime(_selectedDateTime),
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
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
