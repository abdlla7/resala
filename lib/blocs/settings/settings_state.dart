import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum AppThemeType { modernGreen, classicBlue }

class SettingsState extends Equatable {
  final AppThemeType themeType;
  final Brightness brightness;
  final bool notificationsEnabled;
  final bool downloadOfflineEnabled;

  const SettingsState({
    this.themeType = AppThemeType.classicBlue,
    this.brightness = Brightness.light,
    this.notificationsEnabled = true,
    this.downloadOfflineEnabled = false,
  });

  bool get isDarkMode => brightness == Brightness.dark;

  SettingsState copyWith({
    AppThemeType? themeType,
    Brightness? brightness,
    bool? notificationsEnabled,
    bool? downloadOfflineEnabled,
  }) {
    return SettingsState(
      themeType: themeType ?? this.themeType,
      brightness: brightness ?? this.brightness,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      downloadOfflineEnabled:
          downloadOfflineEnabled ?? this.downloadOfflineEnabled,
    );
  }

  ThemeData get currentThemeData {
    switch (themeType) {
      case AppThemeType.modernGreen:
        return brightness == Brightness.light
            ? AppTheme.modernGreenLight
            : AppTheme.modernGreenDark;
      case AppThemeType.classicBlue:
        return brightness == Brightness.light
            ? AppTheme.classicBlueLight
            : AppTheme.classicBlueDark;
    }
  }

  @override
  List<Object?> get props =>
      [themeType, brightness, notificationsEnabled, downloadOfflineEnabled];
}
