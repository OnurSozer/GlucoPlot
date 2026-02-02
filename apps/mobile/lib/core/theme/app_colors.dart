import 'package:flutter/material.dart';

/// Premium color palette with sophisticated dark mode
/// Inspired by Apple's Human Interface Guidelines and premium health apps
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY PALETTE - Warm Coral/Peach (consistent across themes)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primary = Color(0xFFE8A87C);
  static const Color primaryLight = Color(0xFFF8D4B4);
  static const Color primaryDark = Color(0xFFD4886C);

  // Premium accent for dark mode - slightly brighter, more vibrant
  static const Color primaryDarkMode = Color(0xFFFFB896);
  static const Color primaryGlow = Color(0x40E8A87C); // For subtle glow effects

  // ═══════════════════════════════════════════════════════════════════════════
  // SECONDARY PALETTE - Soft Teal
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color secondary = Color(0xFF85C7DE);
  static const Color secondaryLight = Color(0xFFB8E0ED);
  static const Color secondaryDark = Color(0xFF5BA3BC);
  static const Color secondaryDarkMode = Color(0xFF9ED5E8);

  // ═══════════════════════════════════════════════════════════════════════════
  // MEASUREMENT TYPE COLORS
  // Carefully crafted for accessibility in both light and dark modes
  // ═══════════════════════════════════════════════════════════════════════════

  // Glucose - Vibrant coral red
  static const Color glucose = Color(0xFFFF6B6B);
  static const Color glucoseLight = Color(0xFFFFE5E5);
  static const Color glucoseDark = Color(0xFFFF8A8A); // Brighter for dark mode

  // Blood Pressure - Warm terracotta
  static const Color bloodPressure = Color(0xFFE76F51);
  static const Color bloodPressureLight = Color(0xFFFDE8E4);
  static const Color bloodPressureDark = Color(0xFFFF8B70);

  // Heart Rate - Soft pink
  static const Color heartRate = Color(0xFFFF8FA3);
  static const Color heartRateLight = Color(0xFFFFE5EA);
  static const Color heartRateDark = Color(0xFFFFADBD);

  // Weight - Soft purple
  static const Color weight = Color(0xFF9B8FD9);
  static const Color weightLight = Color(0xFFEDE9FF);
  static const Color weightDark = Color(0xFFB8ADEF);

  // Temperature - Warm amber
  static const Color temperature = Color(0xFFFFB347);
  static const Color temperatureLight = Color(0xFFFFF3E0);
  static const Color temperatureDark = Color(0xFFFFCA70);

  // Oxygen - Fresh cyan
  static const Color oxygen = Color(0xFF4ECDC4);
  static const Color oxygenLight = Color(0xFFE0F7F5);
  static const Color oxygenDark = Color(0xFF6EE7DE);

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVITY/LOG TYPE COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Food - Fresh green
  static const Color food = Color(0xFF7CB342);
  static const Color foodLight = Color(0xFFE8F5E9);
  static const Color foodDark = Color(0xFF9CCC65);

  // Sleep - Calm indigo
  static const Color sleep = Color(0xFF5C6BC0);
  static const Color sleepLight = Color(0xFFE8EAF6);
  static const Color sleepDark = Color(0xFF7986CB);

  // Exercise - Energetic orange
  static const Color exercise = Color(0xFFFF7043);
  static const Color exerciseLight = Color(0xFFFBE9E7);
  static const Color exerciseDark = Color(0xFFFF8A65);

  // Medication - Purple
  static const Color medication = Color(0xFFAB47BC);
  static const Color medicationLight = Color(0xFFF3E5F5);
  static const Color medicationDark = Color(0xFFCE93D8);

  // Symptom - Warm yellow
  static const Color symptom = Color(0xFFFFCA28);
  static const Color symptomLight = Color(0xFFFFF8E1);
  static const Color symptomDark = Color(0xFFFFD54F);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF81C784);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFFFB74D);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFEF5350);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF64B5F6);

  // Alert severity
  static const Color alertCritical = Color(0xFFD32F2F);
  static const Color alertHigh = Color(0xFFF57C00);
  static const Color alertMedium = Color(0xFFFFB300);
  static const Color alertLow = Color(0xFF43A047);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME - SURFACES & BACKGROUNDS
  // Clean, minimal, with subtle warmth
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors - Light mode
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Borders & Dividers - Light mode
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM DARK THEME - SURFACES & BACKGROUNDS
  // Rich, layered, with subtle depth and warmth
  // OLED-friendly with proper contrast ratios
  // ═══════════════════════════════════════════════════════════════════════════

  // Base background - Deep blue-black (not pure black, feels premium)
  static const Color darkBackground = Color(0xFF0D0D12);

  // Surface levels - Create depth with subtle elevation
  static const Color darkSurface = Color(0xFF151519);           // Level 0 - Base
  static const Color darkSurfaceElevated = Color(0xFF1C1C22);   // Level 1 - Cards
  static const Color darkSurfaceHighest = Color(0xFF242429);    // Level 2 - Modals

  // Card backgrounds with subtle warmth
  static const Color darkCardBackground = Color(0xFF1A1A20);
  static const Color darkCardBackgroundElevated = Color(0xFF222228);

  // Glass effect colors (for frosted glass effect)
  static const Color darkGlass = Color(0x801A1A20);
  static const Color darkGlassBorder = Color(0x30FFFFFF);

  // Text colors - Dark mode (warm off-white, easier on eyes)
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF71717A);
  static const Color darkTextMuted = Color(0xFF52525B);

  // Borders & Dividers - Dark mode (subtle, not harsh)
  static const Color darkBorder = Color(0xFF2A2A32);
  static const Color darkBorderSubtle = Color(0xFF232329);
  static const Color darkDivider = Color(0xFF27272F);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  // Light mode gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A87C), Color(0xFFD4886C)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD4886C), Color(0xFFE8A87C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );

  // Dark mode gradients - Premium depth
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB896), Color(0xFFE8A87C)],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8A87C), Color(0xFFD4886C)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E24), Color(0xFF1A1A20)],
  );

  // Ambient glow gradients for cards
  static const LinearGradient darkAmbientGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x08FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  // Subtle surface gradient for premium feel
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1C22),
      Color(0xFF18181E),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS & GLOWS
  // ═══════════════════════════════════════════════════════════════════════════

  // Light mode shadows
  static List<BoxShadow> get lightCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lightElevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // Dark mode shadows - Subtle with ambient lighting
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    // Subtle inner glow at top for depth
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.02),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
  ];

  static List<BoxShadow> get darkElevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Glow effect for interactive elements in dark mode
  static List<BoxShadow> darkAccentGlow(Color accentColor) => [
    BoxShadow(
      color: accentColor.withValues(alpha: 0.25),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];
}

/// Extension to get theme-aware colors based on brightness
extension ThemeAwareColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.surface;
  Color get cardColor => isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground;
  Color get elevatedCardColor => isDarkMode ? AppColors.darkCardBackgroundElevated : AppColors.cardBackground;

  // Text
  Color get textPrimaryColor => isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondaryColor => isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiaryColor => isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;

  // Borders
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.border;
  Color get dividerColor => isDarkMode ? AppColors.darkDivider : AppColors.divider;

  // Primary (slightly brighter in dark mode)
  Color get primaryColor => isDarkMode ? AppColors.primaryDarkMode : AppColors.primary;

  // Shadows
  List<BoxShadow> get cardShadow => isDarkMode ? AppColors.darkCardShadow : AppColors.lightCardShadow;

  // Category colors (brighter variants for dark mode)
  Color glucoseColor(bool isLight) => isDarkMode
      ? (isLight ? AppColors.glucoseDark.withValues(alpha: 0.15) : AppColors.glucoseDark)
      : (isLight ? AppColors.glucoseLight : AppColors.glucose);

  Color foodColor(bool isLight) => isDarkMode
      ? (isLight ? AppColors.foodDark.withValues(alpha: 0.15) : AppColors.foodDark)
      : (isLight ? AppColors.foodLight : AppColors.food);
}
