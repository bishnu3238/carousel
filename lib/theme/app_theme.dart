import 'package:flutter/material.dart';

class AppThemes {
  /// Light theme configuration
  static final ThemeData lightTheme = ThemeData.light(useMaterial3: true).copyWith(
    brightness: Brightness.light,
    primaryColor: const Color(0x1F08EDFF),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Color(0x0B011EFF),
      elevation: 0,
      titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.purpleAccent,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  /// Dark theme configuration
  static final ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey[800],
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      color: Colors.blueGrey.shade800,
      elevation: 0,
      titleTextStyle:
          const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.deepPurple),
      trackColor: WidgetStateProperty.all(Colors.deepPurple.shade50),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey.shade800,
      primary: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
  );
}
