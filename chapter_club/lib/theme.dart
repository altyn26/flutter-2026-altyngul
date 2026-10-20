import 'package:flutter/material.dart';

// The only colour literal in the project: the seed for ColorScheme.fromSeed.
const Color _seed = Color(0xFF6750A4);

ThemeData buildLightTheme() {
  return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed));
}

ThemeData buildDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
