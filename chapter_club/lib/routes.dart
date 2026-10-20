import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/route_args.dart';
import 'package:chapter_club/screens/detail_screen.dart';
import 'package:chapter_club/screens/form_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments as DetailArgs;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
    case Routes.form:
      final args = settings.arguments as FormArgs;
      return MaterialPageRoute<Book>(
        settings: settings,
        builder: (_) => FormScreen(args: args),
      );
  }
  return null; // unknown names go to onUnknownRoute
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
