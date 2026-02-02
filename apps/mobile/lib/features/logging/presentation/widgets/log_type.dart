import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Log type enum for UI display
/// Supports localization and theme-aware colors
enum LogType {
  food,
  medication,
  toilet,
  water,
  alcohol,
  exercise,
  sleep,
  stress;

  /// Get localized label
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case LogType.food:
        return l10n.food;
      case LogType.medication:
        return l10n.medicine;
      case LogType.toilet:
        return l10n.toilet;
      case LogType.water:
        return l10n.water;
      case LogType.alcohol:
        return l10n.alcohol;
      case LogType.exercise:
        return l10n.sports;
      case LogType.sleep:
        return l10n.sleep;
      case LogType.stress:
        return l10n.stress;
    }
  }

  /// Get icon for this log type
  IconData get icon {
    switch (this) {
      case LogType.food:
        return Icons.restaurant_rounded;
      case LogType.medication:
        return Icons.medication_rounded;
      case LogType.toilet:
        return Icons.wc_rounded;
      case LogType.water:
        return Icons.water_drop_rounded;
      case LogType.alcohol:
        return Icons.wine_bar_rounded;
      case LogType.exercise:
        return Icons.fitness_center_rounded;
      case LogType.sleep:
        return Icons.bedtime_rounded;
      case LogType.stress:
        return Icons.psychology_rounded;
    }
  }

  /// Get color (light mode)
  Color get color {
    switch (this) {
      case LogType.food:
        return AppColors.food;
      case LogType.medication:
        return AppColors.medication;
      case LogType.toilet:
        return AppColors.secondary;
      case LogType.water:
        return AppColors.secondaryDark;
      case LogType.alcohol:
        return AppColors.symptom;
      case LogType.exercise:
        return AppColors.exercise;
      case LogType.sleep:
        return AppColors.sleep;
      case LogType.stress:
        return AppColors.warning;
    }
  }

  /// Get color for dark mode (brighter)
  Color get darkColor {
    switch (this) {
      case LogType.food:
        return AppColors.foodDark;
      case LogType.medication:
        return AppColors.medicationDark;
      case LogType.toilet:
        return AppColors.secondaryDarkMode;
      case LogType.water:
        return AppColors.infoDark;
      case LogType.alcohol:
        return AppColors.symptomDark;
      case LogType.exercise:
        return AppColors.exerciseDark;
      case LogType.sleep:
        return AppColors.sleepDark;
      case LogType.stress:
        return AppColors.warningDark;
    }
  }

  /// Get theme-aware color
  Color getThemeColor(bool isDark) => isDark ? darkColor : color;

  /// Parse from string (used by router)
  static LogType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'food':
        return LogType.food;
      case 'medication':
        return LogType.medication;
      case 'toilet':
        return LogType.toilet;
      case 'water':
        return LogType.water;
      case 'alcohol':
        return LogType.alcohol;
      case 'exercise':
      case 'sports':
        return LogType.exercise;
      case 'sleep':
        return LogType.sleep;
      case 'stress':
        return LogType.stress;
      default:
        return null;
    }
  }
}
