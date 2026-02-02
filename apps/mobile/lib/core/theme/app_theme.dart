import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Premium app theme configuration
/// Light theme: Clean, minimal with warm accents
/// Dark theme: Rich, layered, premium feel
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      chipTheme: _chipTheme,
      switchTheme: _switchTheme,
      listTileTheme: _listTileTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  /// Premium Dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDarkMode,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDarkMode,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryDarkMode,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceHighest,
        error: AppColors.errorDark,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkBackground,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderSubtle,
      ),
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      elevatedButtonTheme: _darkElevatedButtonTheme,
      outlinedButtonTheme: _darkOutlinedButtonTheme,
      textButtonTheme: _darkTextButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: _darkSnackBarTheme,
      dialogTheme: _darkDialogTheme,
      chipTheme: _darkChipTheme,
      switchTheme: _darkSwitchTheme,
      listTileTheme: _darkListTileTheme,
      bottomSheetTheme: _darkBottomSheetTheme,
      popupMenuTheme: _darkPopupMenuTheme,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  static TextTheme get _darkTextTheme => _textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: AppTypography.headlineSmall,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.darkTextPrimary,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.25,
    ),
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.cardBackground,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
  );

  static const CardThemeData _darkCardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.darkCardBackground,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(
        color: AppColors.darkBorderSubtle,
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonLarge,
    ),
  );

  static final ElevatedButtonThemeData _darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDarkMode,
      foregroundColor: AppColors.darkBackground,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonLarge.copyWith(
        color: AppColors.darkBackground,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: AppTypography.buttonLarge,
    ),
  );

  static final OutlinedButtonThemeData _darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryDarkMode,
      backgroundColor: AppColors.darkCardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
      textStyle: AppTypography.buttonLarge.copyWith(
        color: AppColors.primaryDarkMode,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: AppTypography.buttonMedium,
    ),
  );

  static final TextButtonThemeData _darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryDarkMode,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: AppTypography.buttonMedium,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textTertiary,
    ),
    errorStyle: AppTypography.bodySmall.copyWith(
      color: AppColors.error,
    ),
  );

  static final InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurfaceElevated,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryDarkMode, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorDark, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
    ),
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.darkTextSecondary,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.darkTextTertiary,
    ),
    errorStyle: AppTypography.bodySmall.copyWith(
      color: AppColors.errorDark,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const BottomNavigationBarThemeData _bottomNavTheme =
      BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiary,
    selectedLabelStyle: AppTypography.labelSmall,
    unselectedLabelStyle: AppTypography.labelSmall,
    elevation: 0,
  );

  static const BottomNavigationBarThemeData _darkBottomNavTheme =
      BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primaryDarkMode,
    unselectedItemColor: AppColors.darkTextTertiary,
    selectedLabelStyle: AppTypography.labelSmall,
    unselectedLabelStyle: AppTypography.labelSmall,
    elevation: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textOnDark,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final SnackBarThemeData _darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.darkSurfaceHighest,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.darkTextPrimary,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  static final DialogThemeData _darkDialogTheme = DialogThemeData(
    backgroundColor: AppColors.darkSurfaceElevated,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
    titleTextStyle: AppTypography.headlineSmall.copyWith(
      color: AppColors.darkTextPrimary,
    ),
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.darkTextSecondary,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryLight,
    labelStyle: AppTypography.labelMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    side: BorderSide.none,
  );

  static final ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: AppColors.darkSurfaceElevated,
    selectedColor: AppColors.primaryDark,
    labelStyle: AppTypography.labelMedium.copyWith(
      color: AppColors.darkTextPrimary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.darkBorderSubtle),
    ),
    side: const BorderSide(color: AppColors.darkBorderSubtle),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SWITCH THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.textOnPrimary;
      }
      return AppColors.textTertiary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.surfaceVariant;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return AppColors.border;
    }),
  );

  static final SwitchThemeData _darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white; // Bright white thumb for visibility
      }
      return AppColors.darkTextTertiary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDarkMode;
      }
      return AppColors.darkSurfaceHighest;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return AppColors.darkBorder;
    }),
    thumbIcon: WidgetStateProperty.resolveWith((states) {
      return null; // No icon on thumb for cleaner look
    }),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST TILE THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    textColor: AppColors.textPrimary,
    iconColor: AppColors.textSecondary,
  );

  static const ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    textColor: AppColors.darkTextPrimary,
    iconColor: AppColors.darkTextSecondary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.border,
  );

  static const BottomSheetThemeData _darkBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.darkSurfaceElevated,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.darkBorder,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // POPUP MENU THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static final PopupMenuThemeData _darkPopupMenuTheme = PopupMenuThemeData(
    color: AppColors.darkSurfaceElevated,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
    textStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.darkTextPrimary,
    ),
  );
}
