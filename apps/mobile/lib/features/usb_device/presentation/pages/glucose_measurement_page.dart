import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../measurements/domain/entities/measurement.dart';
import '../../../measurements/domain/repositories/measurement_repository.dart';
import '../../domain/entities/glucose_reading.dart';
import '../bloc/usb_device_bloc.dart';
import '../bloc/usb_device_event.dart';
import '../bloc/usb_device_state.dart';

/// Premium glucose measurement page with USB device integration
/// Step 1: Connect device with instructions
/// Step 2: Display measurement result (auto-saved immediately)
/// Step 3: User can optionally select meal timing and save (overrides auto-save)
class GlucoseMeasurementPage extends StatefulWidget {
  const GlucoseMeasurementPage({super.key});

  @override
  State<GlucoseMeasurementPage> createState() => _GlucoseMeasurementPageState();
}

class _GlucoseMeasurementPageState extends State<GlucoseMeasurementPage> {
  MealTiming? _selectedMealTiming;
  GlucoseReading? _capturedReading;
  bool _isSaving = false;
  bool _allowPop = false;

  /// The ID of the auto-saved measurement in the database
  String? _autoSavedMeasurementId;

  @override
  void initState() {
    super.initState();
    // Clear any previous reading when entering this page for a fresh session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsbDeviceBloc>().add(const UsbClearLatestReadingRequested());
    });
  }

  String _getMealTimingLabel(MealTiming timing, AppLocalizations l10n) {
    switch (timing) {
      case MealTiming.fasting:
        return l10n.localeName == 'tr' ? 'Açlık' : 'Fasting';
      case MealTiming.postMeal:
        return l10n.localeName == 'tr' ? 'Tokluk' : 'After Meal';
      case MealTiming.other:
        return l10n.localeName == 'tr' ? 'Diğer' : 'Other';
    }
  }

  String _getConnectDeviceTitle(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Cihazı Bağlayın' : 'Connect Device';

  String _getConnectDeviceSubtitle(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'USB glikoz ölçüm cihazınızı takın'
          : 'Plug in your USB glucose meter';

  String _getWaitingForReading(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Ölçüm bekleniyor...'
          : 'Waiting for reading...';

  String _getPlaceStripMessage(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Kan şekeri stripini cihaza yerleştirin'
          : 'Insert test strip into the device';

  String _getDeviceReadyMessage(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Cihaz ölçüme hazır'
          : 'Device ready for measurement';

  String _getDeviceReadyTitle(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Cihaz Hazır'
          : 'Device Ready';

  String _getMeasuringTitle(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Ölçüm Yapılıyor'
          : 'Measuring';

  String _getMeasuringMessage(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Lütfen bekleyin...'
          : 'Please wait...';

  String _getMeasurementComplete(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Ölçüm Tamamlandı' : 'Measurement Complete';

  String _getSelectMealTiming(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Ölçüm Zamanı' : 'Measurement Timing';

  String _getSaveButton(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kaydet' : 'Save';

  String _getSavingLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kaydediliyor...' : 'Saving...';

  String _getGlucoseUnit() => 'mg/dL';

  /// Auto-save the reading immediately when received from the device
  Future<void> _autoSaveReading(GlucoseReading reading) async {
    try {
      final repository = sl<MeasurementRepository>();
      final result = await repository.addMeasurement(
        type: MeasurementType.glucose,
        value: reading.concentration,
        unit: 'mg/dL',
        measuredAt: reading.timestamp,
        isAutoSaved: true,
      );

      if (!mounted) return;

      switch (result) {
        case MeasurementSuccess(:final data):
          setState(() {
            _autoSavedMeasurementId = data.id;
          });
        case MeasurementFailure(:final message):
          debugPrint('Auto-save failed: $message');
      }
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }
  }

  /// Save with meal timing: update the existing auto-saved record
  Future<void> _saveWithMealTiming(MealTiming mealTiming) async {
    if (_capturedReading == null || _autoSavedMeasurementId == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final repository = sl<MeasurementRepository>();

      // Get the existing measurement and update it
      final getResult = await repository.getMeasurement(_autoSavedMeasurementId!);

      if (!mounted) return;

      switch (getResult) {
        case MeasurementSuccess(:final data):
          final updated = data.copyWith(
            mealTiming: mealTiming,
            isAutoSaved: false,
          );
          final updateResult = await repository.updateMeasurement(updated);

          if (!mounted) return;

          switch (updateResult) {
            case MeasurementSuccess():
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.localeName == 'tr'
                        ? 'Ölçüm kaydedildi'
                        : 'Measurement saved',
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _popPage();
            case MeasurementFailure(:final message):
              _showErrorSnackBar(message);
              setState(() => _isSaving = false);
          }
        case MeasurementFailure(:final message):
          _showErrorSnackBar(message);
          setState(() => _isSaving = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('$e');
      setState(() => _isSaving = false);
    }
  }

  /// Legacy save for when auto-save hasn't completed yet (fallback)
  Future<void> _saveReading() async {
    if (_capturedReading == null || _selectedMealTiming == null) return;

    // If we have an auto-saved record, update it
    if (_autoSavedMeasurementId != null) {
      await _saveWithMealTiming(_selectedMealTiming!);
      return;
    }

    // Fallback: create new record if auto-save somehow didn't work
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final repository = sl<MeasurementRepository>();
      final result = await repository.addMeasurement(
        type: MeasurementType.glucose,
        value: _capturedReading!.concentration,
        unit: 'mg/dL',
        measuredAt: _capturedReading!.timestamp,
        mealTiming: _selectedMealTiming,
        isAutoSaved: false,
      );

      if (!mounted) return;

      switch (result) {
        case MeasurementSuccess():
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.localeName == 'tr'
                    ? 'Ölçüm kaydedildi'
                    : 'Measurement saved',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _popPage();
        case MeasurementFailure(:final message):
          _showErrorSnackBar(message);
          setState(() => _isSaving = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('$e');
      setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.localeName == 'tr'
              ? 'Kayıt başarısız: $message'
              : 'Failed to save: $message',
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _popPage() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  /// Handle X button or back button press
  Future<void> _handleClose() async {
    // If no reading captured yet, just close
    if (_capturedReading == null) {
      _popPage();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glucoseColor = isDark ? AppColors.glucoseDark : AppColors.glucose;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.localeName == 'tr'
              ? 'Ölçüm kaydedilmedi'
              : 'Measurement not saved',
        ),
        content: Text(
          l10n.localeName == 'tr'
              ? 'Ölçüm zamanı seçmeden çıkmak istediğinize emin misiniz?'
              : 'Are you sure you want to leave without selecting meal timing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: Text(
              l10n.localeName == 'tr' ? 'Sil' : 'Delete',
              style: TextStyle(
                color: isDark ? AppColors.errorDark : AppColors.error,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: glucoseColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.localeName == 'tr' ? 'Kaydet' : 'Save',
            ),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    if (result == 'delete') {
      // User chose "Sil" - keep auto-saved record as-is, just close
      _popPage();
    } else if (result == 'save') {
      // User chose "Kaydet" - show meal timing picker
      await _showMealTimingPicker();
    }
  }

  /// Show meal timing bottom sheet when user chooses "Kaydet" from popup
  Future<void> _showMealTimingPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glucoseColor = isDark ? AppColors.glucoseDark : AppColors.glucose;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;

    final selected = await showModalBottomSheet<MealTiming>(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _getSelectMealTiming(l10n),
                  style: AppTypography.titleMedium.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: MealTiming.values.map((timing) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: timing == MealTiming.fasting ? 0 : 6,
                          right: timing == MealTiming.other ? 0 : 6,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop(timing);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorderSubtle
                                    : AppColors.border,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  timing == MealTiming.fasting
                                      ? Icons.no_food_rounded
                                      : timing == MealTiming.postMeal
                                          ? Icons.restaurant_rounded
                                          : Icons.schedule_rounded,
                                  color: glucoseColor,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getMealTimingLabel(timing, l10n),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    // Save with selected meal timing
    await _saveWithMealTiming(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return PopScope(
      canPop: _allowPop || _capturedReading == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleClose();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            onPressed: _handleClose,
          ),
          title: Text(
            l10n.glucoseMeasurement,
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<UsbDeviceBloc, UsbDeviceState>(
          listener: (context, state) {
            // Capture reading when received and auto-save immediately
            if (state.latestReading != null && _capturedReading == null) {
              setState(() {
                _capturedReading = state.latestReading;
              });
              HapticFeedback.heavyImpact();
              // Auto-save to database immediately
              _autoSaveReading(state.latestReading!);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _capturedReading != null
                    ? _buildMeasurementResultView(l10n, isDark)
                    : _buildConnectionView(state, l10n, isDark),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionView(
    UsbDeviceState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final glucoseColor = isDark ? AppColors.glucoseDark : AppColors.glucose;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;

    return Column(
      children: [
        const Spacer(flex: 1),

        // Main icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glucoseColor.withValues(alpha: isDark ? 0.2 : 0.15),
            border: Border.all(
              color: glucoseColor.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: Center(
            child: state.isMeasuring
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: glucoseColor,
                    ),
                  )
                : Icon(
                    state.isConnected
                        ? (state.isDeviceReady
                            ? Icons.water_drop_rounded
                            : Icons.bloodtype_rounded)
                        : Icons.usb_rounded,
                    size: 56,
                    color: state.isDeviceReady ? AppColors.success : glucoseColor,
                  ),
          ),
        ),

        const SizedBox(height: 32),

        // Status text
        Text(
          state.isConnected
              ? (state.isMeasuring
                  ? _getMeasuringTitle(l10n)
                  : (state.isDeviceReady
                      ? _getDeviceReadyTitle(l10n)
                      : _getWaitingForReading(l10n)))
              : _getConnectDeviceTitle(l10n),
          style: AppTypography.headlineSmall.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isConnected
              ? (state.isMeasuring
                  ? _getMeasuringMessage(l10n)
                  : (state.isDeviceReady
                      ? _getDeviceReadyMessage(l10n)
                      : _getPlaceStripMessage(l10n)))
              : _getConnectDeviceSubtitle(l10n),
          style: AppTypography.bodyLarge.copyWith(color: textSecondary),
          textAlign: TextAlign.center,
        ),

        const Spacer(flex: 1),

        // Connection status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: state.isConnected
                  ? AppColors.success.withValues(alpha: 0.5)
                  : (isDark ? AppColors.darkBorderSubtle : AppColors.border),
              width: 1.5,
            ),
            boxShadow: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (state.isConnected ? AppColors.success : glucoseColor)
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      state.isConnected
                          ? Icons.check_circle_rounded
                          : Icons.usb_rounded,
                      color: state.isConnected ? AppColors.success : glucoseColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isConnected
                              ? (l10n.localeName == 'tr' ? 'Bağlandı' : 'Connected')
                              : (l10n.localeName == 'tr' ? 'Bağlantı Bekleniyor' : 'Waiting for Connection'),
                          style: AppTypography.titleMedium.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (state.deviceInfo != null)
                          Text(
                            state.deviceInfo!.deviceId,
                            style: AppTypography.bodySmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: glucoseColor,
                      ),
                    ),
                ],
              ),

              // Error message
              if (state.hasError && state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.errorDark : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: isDark ? AppColors.errorDark : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.errorDark : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<UsbDeviceBloc>().add(const UsbDeviceCheckRequested());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: glucoseColor,
                      side: BorderSide(color: glucoseColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.retry),
                  ),
                ),
              ],

              // Permission required
              if (state.permissionRequired) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.localeName == 'tr'
                              ? 'USB izni gerekli'
                              : 'USB permission required',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<UsbDeviceBloc>().add(const UsbDeviceCheckRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: glucoseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.localeName == 'tr' ? 'İzin Ver' : 'Grant Permission',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionStep(
                1,
                l10n.localeName == 'tr'
                    ? 'USB cihazını telefona bağlayın'
                    : 'Connect USB device to phone',
                state.isConnected,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInstructionStep(
                2,
                l10n.localeName == 'tr'
                    ? 'Test stripini cihaza yerleştirin'
                    : 'Insert test strip into device',
                state.isDeviceReady || state.isMeasuring,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInstructionStep(
                3,
                l10n.localeName == 'tr'
                    ? 'Kan örneğini stripe uygulayın'
                    : 'Apply blood sample to strip',
                state.isMeasuring,
                isDark,
              ),
            ],
          ),
        ),

        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildInstructionStep(
    int stepNumber,
    String text,
    bool isComplete,
    bool isDark,
  ) {
    final glucoseColor = isDark ? AppColors.glucoseDark : AppColors.glucose;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textTertiary;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.success
                : glucoseColor.withValues(alpha: 0.2),
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: AppTypography.labelMedium.copyWith(
                      color: glucoseColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: isComplete ? textPrimary : textSecondary,
              decoration: isComplete ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementResultView(AppLocalizations l10n, bool isDark) {
    final glucoseColor = isDark ? AppColors.glucoseDark : AppColors.glucose;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;

    final concentration = _capturedReading!.concentration;

    // Determine status color based on glucose level
    Color statusColor;
    String statusText;
    if (concentration < 70) {
      statusColor = AppColors.warning;
      statusText = l10n.localeName == 'tr' ? 'Düşük' : 'Low';
    } else if (concentration > 180) {
      statusColor = isDark ? AppColors.errorDark : AppColors.error;
      statusText = l10n.localeName == 'tr' ? 'Yüksek' : 'High';
    } else {
      statusColor = AppColors.success;
      statusText = l10n.localeName == 'tr' ? 'Normal' : 'Normal';
    }

    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.15),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getMeasurementComplete(l10n),
          style: AppTypography.titleLarge.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 32),

        // Glucose reading card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [glucoseColor.withValues(alpha: 0.3), glucoseColor.withValues(alpha: 0.15)]
                  : [glucoseColor.withValues(alpha: 0.2), glucoseColor.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: glucoseColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    concentration.toStringAsFixed(0),
                    style: AppTypography.displayLarge.copyWith(
                      color: glucoseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _getGlucoseUnit(),
                      style: AppTypography.titleMedium.copyWith(
                        color: glucoseColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.labelLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Meal timing selection
        Text(
          _getSelectMealTiming(l10n),
          style: AppTypography.titleMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: MealTiming.values.map((timing) {
            final isSelected = _selectedMealTiming == timing;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: timing == MealTiming.fasting ? 0 : 6,
                  right: timing == MealTiming.other ? 0 : 6,
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMealTiming = timing);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? glucoseColor
                          : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? glucoseColor
                            : (isDark ? AppColors.darkBorderSubtle : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: glucoseColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          timing == MealTiming.fasting
                              ? Icons.no_food_rounded
                              : timing == MealTiming.postMeal
                                  ? Icons.restaurant_rounded
                                  : Icons.schedule_rounded,
                          color: isSelected
                              ? Colors.white
                              : textSecondary,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMealTimingLabel(timing, l10n),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Spacer(),

        // Save button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedMealTiming != null && !_isSaving
                ? _saveReading
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: glucoseColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: glucoseColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getSavingLabel(l10n),
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _getSaveButton(l10n),
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
