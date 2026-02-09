import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Font size scale options
enum FontSizeScale { small, medium, large }

/// Settings provider for app-wide settings like theme and locale
class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _fontSizeKey = 'font_size';
  static const String _doctorPhoneKey = 'doctor_phone';
  static const String _usualSleepTimeKey = 'usual_sleep_time';

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('tr');
  FontSizeScale _fontSizeScale = FontSizeScale.medium;
  String? _doctorPhone;
  TimeOfDay _usualSleepTime = const TimeOfDay(hour: 23, minute: 0); // Default 11 PM

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  FontSizeScale get fontSizeScale => _fontSizeScale;
  String? get doctorPhone => _doctorPhone;
  TimeOfDay get usualSleepTime => _usualSleepTime;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Get text scale factor based on font size setting
  double get textScaleFactor {
    switch (_fontSizeScale) {
      case FontSizeScale.small:
        return 0.85;
      case FontSizeScale.medium:
        return 1.0;
      case FontSizeScale.large:
        return 1.2;
    }
  }

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
  ];

  /// Locale display names
  static const Map<String, String> localeNames = {
    'en': 'English',
    'tr': 'Türkçe',
  };

  /// Initialize settings from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    // Load locale
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }

    // Load font size
    final fontSizeIndex = prefs.getInt(_fontSizeKey);
    if (fontSizeIndex != null && fontSizeIndex < FontSizeScale.values.length) {
      _fontSizeScale = FontSizeScale.values[fontSizeIndex];
    }

    // Load doctor phone
    _doctorPhone = prefs.getString(_doctorPhoneKey);

    // Load usual sleep time
    final sleepTimeString = prefs.getString(_usualSleepTimeKey);
    if (sleepTimeString != null) {
      final parts = sleepTimeString.split(':');
      if (parts.length >= 2) {
        _usualSleepTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 23,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Toggle between light and dark mode
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Get display name for current locale
  String get currentLocaleName => localeNames[_locale.languageCode] ?? 'English';

  /// Set font size scale
  Future<void> setFontSizeScale(FontSizeScale scale) async {
    if (_fontSizeScale == scale) return;

    _fontSizeScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, scale.index);
  }

  /// Set doctor phone number
  Future<void> setDoctorPhone(String? phone) async {
    if (_doctorPhone == phone) return;

    _doctorPhone = phone;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (phone != null) {
      await prefs.setString(_doctorPhoneKey, phone);
    } else {
      await prefs.remove(_doctorPhoneKey);
    }
  }

  /// Get display name for font size
  String getFontSizeDisplayName(FontSizeScale scale, String small, String medium, String large) {
    switch (scale) {
      case FontSizeScale.small:
        return small;
      case FontSizeScale.medium:
        return medium;
      case FontSizeScale.large:
        return large;
    }
  }

  /// Set usual sleep time
  Future<void> setUsualSleepTime(TimeOfDay time) async {
    if (_usualSleepTime == time) return;

    _usualSleepTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_usualSleepTimeKey, timeString);

    // TODO: Also sync to Supabase patient profile when online
  }
}
