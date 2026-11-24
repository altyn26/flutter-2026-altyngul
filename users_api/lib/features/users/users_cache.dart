import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> users) async {
    if (kIsWeb) return; // в браузере нет файловой системы
    final f = await _file();
    await f.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
  }

  /// null = кэша нет (или файл повреждён).
  Future<List<User>?> load() async {
    if (kIsWeb) return null;
    final f = await _file();
    if (!await f.exists()) return null;
    try {
      final raw = jsonDecode(await f.readAsString()) as List<dynamic>;
      return [for (final j in raw) User.fromJson(j as Map<String, dynamic>)];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
