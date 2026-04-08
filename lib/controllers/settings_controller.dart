import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

enum AppThemeType { modernGreen, classicBlue }

class SettingsController with ChangeNotifier {
  // Constants for SharedPreferences keys
  static const String _keyThemeType = 'theme_type';
  static const String _keyLocale = 'locale';
  static const String _keyIsDarkMode = 'is_dark_mode';

  // State with required defaults
  AppThemeType _currentThemeType = AppThemeType.classicBlue;
  Locale _currentLocale = const Locale('ar');
  Brightness _brightness = Brightness.light;

  SettingsController();

  // Getters
  AppThemeType get currentThemeType => _currentThemeType;
  Locale get currentLocale => _currentLocale;
  Brightness get brightness => _brightness;
  bool get isDarkMode => _brightness == Brightness.dark;

  ThemeData get currentThemeData {
    switch (_currentThemeType) {
      case AppThemeType.modernGreen:
        return _brightness == Brightness.light
            ? AppTheme.modernGreenLight
            : AppTheme.modernGreenDark;
      case AppThemeType.classicBlue:
        return _brightness == Brightness.light
            ? AppTheme.classicBlueLight
            : AppTheme.classicBlueDark;
    }
  }

  bool get isArabic => _currentLocale.languageCode == 'ar';

  // Persistence Logic
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme Type
    final themeName = prefs.getString(_keyThemeType);
    if (themeName != null) {
      if (themeName == AppThemeType.modernGreen.toString()) {
        _currentThemeType = AppThemeType.modernGreen;
      } else {
        _currentThemeType = AppThemeType.classicBlue;
      }
    }

    // Load Brightness
    final isDark = prefs.getBool(_keyIsDarkMode);
    if (isDark != null) {
      _brightness = isDark ? Brightness.dark : Brightness.light;
    }

    // Load Locale
    final languageCode = prefs.getString(_keyLocale);
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
    }

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeType, _currentThemeType.toString());
    await prefs.setBool(_keyIsDarkMode, _brightness == Brightness.dark);
    await prefs.setString(_keyLocale, _currentLocale.languageCode);
  }

  // Actions
  void setTheme(AppThemeType type) {
    if (_currentThemeType != type) {
      _currentThemeType = type;
      _saveSettings();
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_currentThemeType == AppThemeType.modernGreen) {
      setTheme(AppThemeType.classicBlue);
    } else {
      setTheme(AppThemeType.modernGreen);
    }
  }

  void setBrightness(Brightness brightness) {
    if (_brightness != brightness) {
      _brightness = brightness;
      _saveSettings();
      notifyListeners();
    }
  }

  void toggleBrightness() {
    setBrightness(
      _brightness == Brightness.light ? Brightness.dark : Brightness.light,
    );
  }

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _saveSettings();
      notifyListeners();
    }
  }

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      setLocale(const Locale('ar'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}
