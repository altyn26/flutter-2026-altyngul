import 'package:flutter/material.dart';
import 'package:chapter_club/routes.dart';
import 'package:chapter_club/screens/home_shell.dart';
import 'package:chapter_club/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chapter Club',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      routes: {
        Routes.home: (context) =>
            HomeShell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
