import 'package:flutter/material.dart';
import 'package:chapter_club/route_args.dart';
import 'package:chapter_club/screens/detail_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments as DetailArgs;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
  }
  return null; // неизвестное имя уходит в onUnknownRoute
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
