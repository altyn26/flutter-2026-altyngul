import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      // composition root: the only place that says http.Client()
      create: (_) {
        final model = UsersModel(UserRepository(ApiClient(http.Client())));
        unawaited(model.load());
        return model;
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // allow pull-to-refresh with the mouse in Chrome
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: const UsersScreen(),
    );
  }
}
