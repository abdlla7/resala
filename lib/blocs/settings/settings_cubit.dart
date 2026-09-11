import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _keyThemeType = 'theme_type';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyDownloadOffline = 'download_offline_enabled';

  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    AppThemeType themeType = AppThemeType.classicBlue;
    final themeName = prefs.getString(_keyThemeType);
    if (themeName == AppThemeType.modernGreen.toString()) {
      themeType = AppThemeType.modernGreen;
    }

    Brightness brightness = Brightness.light;
    final isDark = prefs.getBool(_keyIsDarkMode);
    if (isDark == true) {
      brightness = Brightness.dark;
    }

    final notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    final downloadOfflineEnabled =
        prefs.getBool(_keyDownloadOffline) ?? false;

    emit(
      SettingsState(
        themeType: themeType,
        brightness: brightness,
        notificationsEnabled: notificationsEnabled,
        downloadOfflineEnabled: downloadOfflineEnabled,
      ),
    );
  }

  Future<void> _saveSettings(SettingsState s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeType, s.themeType.toString());
    await prefs.setBool(_keyIsDarkMode, s.brightness == Brightness.dark);
    await prefs.setBool(_keyNotifications, s.notificationsEnabled);
    await prefs.setBool(_keyDownloadOffline, s.downloadOfflineEnabled);
  }

  void setTheme(AppThemeType type) {
    if (state.themeType == type) return;
    final next = state.copyWith(themeType: type);
    emit(next);
    _saveSettings(next);
  }

  void toggleBrightness() {
    final next = state.copyWith(
      brightness: state.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );
    emit(next);
    _saveSettings(next);
  }

  void toggleNotifications() {
    final next =
        state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    emit(next);
    _saveSettings(next);
  }

  void toggleDownloadOffline() {
    final next = state.copyWith(
      downloadOfflineEnabled: !state.downloadOfflineEnabled,
    );
    emit(next);
    _saveSettings(next);
  }
}
