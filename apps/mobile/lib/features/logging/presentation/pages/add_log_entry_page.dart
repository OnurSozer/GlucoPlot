import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_log.dart' as domain;
import '../bloc/daily_log_bloc.dart';
import '../widgets/log_type.dart';

/// Add log entry page with full localization and dark mode support
/// Enhanced with preset quick actions, simplified time picker, and voice input
class AddLogEntryPage extends StatefulWidget {
  final String? initialType;

  const AddLogEntryPage({super.key, this.initialType});

  @override
  State<AddLogEntryPage> createState() => _AddLogEntryPageState();
}

class _AddLogEntryPageState extends State<AddLogEntryPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late LogType _selectedType;
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;

  // Voice input
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  TextEditingController? _activeVoiceController;

  // Type-specific controllers
  final _caloriesController = TextEditingController();
  final _carbsController = TextEditingController();
  final _durationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _amountController = TextEditingController();
  final _stressLevelController = TextEditingController();
  final _triggersController = TextEditingController();

  String? _sleepQuality;
  String? _alcoholType;
  String? _toiletType;

  @override
  void initState() {
    super.initState();
    _selectedType = LogType.fromString(widget.initialType) ?? LogType.food;
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _durationController.dispose();
    _dosageController.dispose();
    _amountController.dispose();
    _stressLevelController.dispose();
    _triggersController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening(TextEditingController controller) async {
    if (!_speech.isAvailable) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isListening = true;
      _activeVoiceController = controller;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;
        });
      },
      localeId: Localizations.localeOf(context).languageCode == 'tr' ? 'tr_TR' : 'en_US',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _activeVoiceController = null;
    });
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

  void _selectPreset(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      _titleController.text = title;
    });
  }

  /// Map UI LogType to domain LogType
  domain.LogType _mapToDomainLogType() {
    switch (_selectedType) {
      case LogType.food:
        return domain.LogType.food;
      case LogType.medication:
        return domain.LogType.medication;
      case LogType.exercise:
        return domain.LogType.exercise;
      case LogType.sleep:
        return domain.LogType.sleep;
      case LogType.stress:
        return domain.LogType.symptom; // Stress is stored as symptom
      case LogType.water:
      case LogType.alcohol:
      case LogType.toilet:
        return domain.LogType.note; // These are stored as notes with metadata
    }
  }

  /// Build metadata based on log type
  Map<String, dynamic> _buildMetadata() {
    final metadata = <String, dynamic>{};

    switch (_selectedType) {
      case LogType.food:
        if (_caloriesController.text.isNotEmpty) {
          metadata['calories'] = int.tryParse(_caloriesController.text);
        }
        if (_carbsController.text.isNotEmpty) {
          metadata['carbs_grams'] = int.tryParse(_carbsController.text);
        }
        break;

      case LogType.sleep:
        if (_durationController.text.isNotEmpty) {
          metadata['hours'] = double.tryParse(_durationController.text);
        }
        if (_sleepQuality != null) {
          metadata['quality'] = _sleepQuality;
        }
        break;

      case LogType.exercise:
        if (_durationController.text.isNotEmpty) {
          metadata['duration_minutes'] = int.tryParse(_durationController.text);
        }
        if (_caloriesController.text.isNotEmpty) {
          metadata['calories_burned'] = int.tryParse(_caloriesController.text);
        }
        break;

      case LogType.medication:
        if (_dosageController.text.isNotEmpty) {
          metadata['dosage'] = _dosageController.text;
        }
        break;

      case LogType.water:
        metadata['type'] = 'water';
        if (_amountController.text.isNotEmpty) {
          metadata['amount_ml'] = int.tryParse(_amountController.text);
        }
        break;

      case LogType.alcohol:
        metadata['type'] = 'alcohol';
        if (_amountController.text.isNotEmpty) {
          metadata['amount_ml'] = int.tryParse(_amountController.text);
        }
        if (_alcoholType != null) {
          metadata['alcohol_type'] = _alcoholType;
        }
        break;

      case LogType.toilet:
        metadata['type'] = 'toilet';
        if (_toiletType != null) {
          metadata['toilet_type'] = _toiletType;
        }
        break;

      case LogType.stress:
        if (_stressLevelController.text.isNotEmpty) {
          metadata['stress_level'] = int.tryParse(_stressLevelController.text);
        }
        if (_triggersController.text.isNotEmpty) {
          metadata['triggers'] = _triggersController.text;
        }
        break;
    }

    return metadata;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_titleController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterTitle),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      // Dispatch DailyLogAdded event to BLoC
      context.read<DailyLogBloc>().add(DailyLogAdded(
        logDate: _selectedDateTime,
        logType: _mapToDomainLogType(),
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        metadata: _buildMetadata(),
        loggedAt: _selectedDateTime,
      ));

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  l10n.entrySaved,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.addEntry,
          style: AppTypography.titleLarge.copyWith(color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const AppLoadingIndicator(size: 20)
                : Text(
                    l10n.save,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show activity header if type was pre-selected, otherwise show selector
            if (widget.initialType != null)
              _buildActivityHeader(l10n, isDark, cardBg, borderColor)
            else ...[
              Text(
                l10n.whatAreYouLogging,
                style: AppTypography.labelMedium.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(l10n, isDark),
            ],

            const SizedBox(height: 24),

            // Quick presets for food type
            if (_selectedType == LogType.food) ...[
              _buildQuickPresets(l10n, isDark, primaryColor),
              const SizedBox(height: 16),
            ],

            // Title input with voice
            _buildTextFieldWithVoice(
              controller: _titleController,
              label: l10n.title,
              hint: _getHintForType(l10n, _selectedType),
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Description input with voice
            _buildTextFieldWithVoice(
              controller: _descriptionController,
              label: l10n.descriptionOptional,
              hint: l10n.addMoreDetails,
              maxLines: 3,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Simplified time selector
            Text(
              l10n.when,
              style: AppTypography.labelMedium.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 12),
            _buildSimplifiedTimePicker(l10n, isDark, cardBg, borderColor, textPrimary, textSecondary, primaryColor),

            const SizedBox(height: 24),

            // Type-specific fields
            _buildTypeSpecificFields(l10n, isDark, textSecondary),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Quick preset buttons for food type
  Widget _buildQuickPresets(AppLocalizations l10n, bool isDark, Color primaryColor) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    final presets = [
      (_getBreakfastLabel(l10n), Icons.wb_sunny_rounded),
      (_getLunchLabel(l10n), Icons.wb_twilight_rounded),
      (_getDinnerLabel(l10n), Icons.nights_stay_rounded),
      (_getSnackLabel(l10n), Icons.cookie_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getQuickSelectLabel(l10n),
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: presets.map((preset) {
            final isSelected = _titleController.text == preset.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _selectPreset(preset.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.15)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          preset.$2,
                          color: isSelected ? primaryColor : textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset.$1,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? primaryColor : textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getOrEnterCustomLabel(l10n),
          style: AppTypography.bodySmall.copyWith(
            color: textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Localization helpers for presets
  String _getQuickSelectLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Hızlı Seçim' : 'Quick Select';
  String _getBreakfastLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kahvaltı' : 'Breakfast';
  String _getLunchLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Öğle' : 'Lunch';
  String _getDinnerLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Akşam' : 'Dinner';
  String _getSnackLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Atıştırmalık' : 'Snack';
  String _getOrEnterCustomLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Veya aşağıya özel başlık girin' : 'Or enter custom title below';
  String _getNowLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Şimdi' : 'Now';
  String _getMinAgoLabel(AppLocalizations l10n, int min) =>
      l10n.localeName == 'tr' ? '$min dk önce' : '$min min ago';
  String _getHourAgoLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? '1 saat önce' : '1 hour ago';
  String _getCustomTimeLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Özel' : 'Custom';

  /// Simplified time picker with quick buttons
  Widget _buildSimplifiedTimePicker(
    AppLocalizations l10n,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final now = DateTime.now();
    final isNow = _selectedDateTime.difference(now).inMinutes.abs() < 2;
    final is15MinAgo = (_selectedDateTime.difference(now).inMinutes + 15).abs() < 2;
    final is30MinAgo = (_selectedDateTime.difference(now).inMinutes + 30).abs() < 2;
    final is1HourAgo = (_selectedDateTime.difference(now).inMinutes + 60).abs() < 2;
    final isCustom = !isNow && !is15MinAgo && !is30MinAgo && !is1HourAgo;

    final quickOptions = [
      (_getNowLabel(l10n), 0, isNow),
      (_getMinAgoLabel(l10n, 15), 15, is15MinAgo),
      (_getMinAgoLabel(l10n, 30), 30, is30MinAgo),
      (_getHourAgoLabel(l10n), 60, is1HourAgo),
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
                        _getCustomTimeLabel(l10n),
                        style: AppTypography.labelSmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        '${_formatDate(_selectedDateTime, l10n)} - ${_formatTime(_selectedDateTime)}',
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

  /// Simple header showing the pre-selected activity type
  Widget _buildActivityHeader(
    AppLocalizations l10n,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    final typeColor = _selectedType.getThemeColor(isDark);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedType.icon,
              color: typeColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _selectedType.getLabel(l10n),
            style: AppTypography.titleMedium.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n, bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: LogType.values.map((type) {
        final isSelected = type == _selectedType;
        final typeColor = type.getThemeColor(isDark);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedType = type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? typeColor.withValues(alpha: isDark ? 0.18 : 0.15)
                  : surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? typeColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: isDark && isSelected
                  ? [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  color: isSelected ? typeColor : textTertiary,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  type.getLabel(l10n),
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? typeColor : textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextFieldWithVoice({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final fillColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final isActiveVoice = _isListening && _activeVoiceController == controller;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyLarge.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        labelStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        suffixIcon: _speech.isAvailable
            ? IconButton(
                icon: Icon(
                  isActiveVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: isActiveVoice ? AppColors.error : textTertiary,
                ),
                onPressed: isActiveVoice
                    ? _stopListening
                    : () => _startListening(controller),
              )
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final fillColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyLarge.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        labelStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    switch (_selectedType) {
      case LogType.food:
        return _buildFoodFields(l10n, isDark, textSecondary);
      case LogType.sleep:
        return _buildSleepFields(l10n, isDark, textSecondary);
      case LogType.exercise:
        return _buildExerciseFields(l10n, isDark, textSecondary);
      case LogType.medication:
        return _buildMedicationFields(l10n, isDark, textSecondary);
      case LogType.water:
        return _buildWaterFields(l10n, isDark, textSecondary);
      case LogType.alcohol:
        return _buildAlcoholFields(l10n, isDark, textSecondary);
      case LogType.toilet:
        return _buildToiletFields(l10n, isDark, textSecondary);
      case LogType.stress:
        return _buildStressFields(l10n, isDark, textSecondary);
    }
  }

  Widget _buildFoodFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nutritionOptional,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _caloriesController,
                label: l10n.calories,
                hint: '350',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _carbsController,
                label: l10n.carbsG,
                hint: '45',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sleepDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _durationController,
          label: l10n.durationHours,
          hint: '7.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quality,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [l10n.poor, l10n.fair, l10n.good, l10n.excellent].map((quality) {
            final isSelected = _sleepQuality == quality;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _sleepQuality = quality);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withValues(alpha: 0.15) : surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      quality,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? primaryColor : textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExerciseFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exerciseDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _durationController,
                label: l10n.durationMin,
                hint: '30',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _caloriesController,
                label: l10n.caloriesBurned,
                hint: '150',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicationDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _dosageController,
          label: l10n.dosage,
          hint: '500mg',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildWaterFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    // Smart defaults - quick glass selection
    final glassOptions = ['1', '2', '3', '4'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.waterDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        // Quick glass selector
        Row(
          children: glassOptions.map((glasses) {
            final isSelected = _durationController.text == glasses;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _durationController.text = glasses;
                      _amountController.text = (int.parse(glasses) * 250).toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withValues(alpha: 0.15) : surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          color: isSelected ? primaryColor : textSecondary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$glasses ${l10n.glasses}',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? primaryColor : textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
        _buildTextField(
          controller: _amountController,
          label: l10n.amountMl,
          hint: '250',
          keyboardType: TextInputType.number,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAlcoholFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.alcoholDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _amountController,
          label: l10n.drinks,
          hint: '1',
          keyboardType: TextInputType.number,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.alcoholType,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [l10n.beer, l10n.wine, l10n.spirits, l10n.other].map((type) {
            final isSelected = _alcoholType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _alcoholType = type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withValues(alpha: 0.15) : surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? primaryColor : textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToiletFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.toiletDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.toiletType,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [l10n.urination, l10n.bowelMovement, l10n.both].map((type) {
            final isSelected = _toiletType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _toiletType = type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withValues(alpha: 0.15) : surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? primaryColor : textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStressFields(AppLocalizations l10n, bool isDark, Color textSecondary) {
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;

    // Stress level 1-10 quick selector
    final stressLevels = List.generate(10, (i) => (i + 1).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stressDetails,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.stressLevel,
          style: AppTypography.labelMedium.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        // Stress level buttons in 2 rows
        Column(
          children: [
            Row(
              children: stressLevels.sublist(0, 5).map((level) {
                final isSelected = _stressLevelController.text == level;
                final levelInt = int.parse(level);
                final color = levelInt <= 3
                    ? AppColors.success
                    : levelInt <= 6
                        ? AppColors.warning
                        : AppColors.error;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _stressLevelController.text = level);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.2))
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected ? color : textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: stressLevels.sublist(5, 10).map((level) {
                final isSelected = _stressLevelController.text == level;
                final levelInt = int.parse(level);
                final color = levelInt <= 3
                    ? AppColors.success
                    : levelInt <= 6
                        ? AppColors.warning
                        : AppColors.error;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _stressLevelController.text = level);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.2))
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected ? color : textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithVoice(
          controller: _triggersController,
          label: l10n.triggers,
          hint: l10n.hintStress,
          maxLines: 2,
          isDark: isDark,
        ),
      ],
    );
  }

  String _getHintForType(AppLocalizations l10n, LogType type) {
    switch (type) {
      case LogType.food:
        return l10n.hintFood;
      case LogType.sleep:
        return l10n.hintSleep;
      case LogType.exercise:
        return l10n.hintExercise;
      case LogType.medication:
        return l10n.hintMedication;
      case LogType.water:
        return l10n.hintWater;
      case LogType.alcohol:
        return l10n.hintAlcohol;
      case LogType.toilet:
        return l10n.hintToilet;
      case LogType.stress:
        return l10n.hintStress;
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return l10n.today;
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return l10n.yesterday;
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
