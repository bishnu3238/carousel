import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode'; // Key to store theme in SharedPreferences
  bool _isDarkMode = false;

  /// Constructor to load the theme from shared preferences
  ThemeManager() {
    _loadThemeFromStorage();
  }

  /// Getter for the current theme mode
  bool get isDarkMode => _isDarkMode;

  /// Getter for the current ThemeData
  ThemeData get themeData => _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  /// Toggle between dark and light theme
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemeToStorage();
    notifyListeners();
  }

  /// Set a specific theme mode
  void setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _saveThemeToStorage();
    notifyListeners();
  }

  /// Load the theme mode from SharedPreferences
  Future<void> _loadThemeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false; // Default to light theme
    notifyListeners();
  }

  /// Save the theme mode to SharedPreferences
  Future<void> _saveThemeToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
