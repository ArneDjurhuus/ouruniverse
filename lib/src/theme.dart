import 'package:flutter/material.dart';

ThemeData buildCalmTheme() {
  const seed = Color(0xFF6AA6A2); // soft teal
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: true,
      elevation: 0,
    ),
  );
}
