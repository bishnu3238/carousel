import 'package:flutter/material.dart';

import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDarkMode = false; // Tracks the current theme mode

  ThemeManager({bool isDarkMode = false}) {
    _isDarkMode = isDarkMode;
  }

  /// Get the current theme mode
  bool get isDarkMode => _isDarkMode;

  /// Get the current theme data
  ThemeData get themeData => _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  /// Toggle between light and dark themes
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Set a specific theme mode
  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
