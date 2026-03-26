import 'package:flutter/material.dart';

abstract class AppTheme {
  AppTheme._();

  static const _primary   = Color(0xFF2563EB);
  static const _secondary = Color(0xFF10B981);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,          // Force light — never inherit system dark
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      secondary: _secondary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      secondary: _secondary,
      brightness: Brightness.dark,
    ),
  );
}
