import 'package:flutter/material.dart';

/// App color palette inspired by Apple Health
/// Soft, warm tones with gradient accents
class AppColors {
  AppColors._();

  // Primary - Warm peach/coral gradient (like the Apple Health header)
  static const Color primary = Color(0xFFE8A87C);
  static const Color primaryLight = Color(0xFFF8D4B4);
  static const Color primaryDark = Color(0xFFD4886C);

  // Secondary - Soft teal for contrast
  static const Color secondary = Color(0xFF85C7DE);
  static const Color secondaryLight = Color(0xFFB8E0ED);
  static const Color secondaryDark = Color(0xFF5BA3BC);

  // Accent colors for different measurement types
  static const Color glucose = Color(0xFFFF6B6B);
  static const Color glucoseLight = Color(0xFFFFE5E5);
  static const Color bloodPressure = Color(0xFFE76F51);
  static const Color bloodPressureLight = Color(0xFFFDE8E4);
  static const Color heartRate = Color(0xFFFF8FA3);
  static const Color heartRateLight = Color(0xFFFFE5EA);
  static const Color weight = Color(0xFF9B8FD9);
  static const Color weightLight = Color(0xFFEDE9FF);
  static const Color temperature = Color(0xFFFFB347);
  static const Color temperatureLight = Color(0xFFFFF3E0);
  static const Color oxygen = Color(0xFF4ECDC4);
  static const Color oxygenLight = Color(0xFFE0F7F5);

  // Log type colors
  static const Color food = Color(0xFF7CB342);
  static const Color foodLight = Color(0xFFE8F5E9);
  static const Color sleep = Color(0xFF5C6BC0);
  static const Color sleepLight = Color(0xFFE8EAF6);
  static const Color exercise = Color(0xFFFF7043);
  static const Color exerciseLight = Color(0xFFFBE9E7);
  static const Color medication = Color(0xFFAB47BC);
  static const Color medicationLight = Color(0xFFF3E5F5);
  static const Color symptom = Color(0xFFFFCA28);
  static const Color symptomLight = Color(0xFFFFF8E1);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Alert severity
  static const Color alertCritical = Color(0xFFD32F2F);
  static const Color alertHigh = Color(0xFFF57C00);
  static const Color alertMedium = Color(0xFFFFB300);
  static const Color alertLow = Color(0xFF43A047);

  // Neutrals - Soft grays for backgrounds and text
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Gradients
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

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF3C3C3C);
}
