import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (e) {
      error = e;
      fromCache = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<User> visible(String? city) => city == null
      ? items
      : items.where((u) => u.address.city == city).toList();

  /// Used by the "New user" form (Level 5). Throws ApiException.
  Future<User> add(User draft) async {
    final created = await _repo.create(draft);
    items = [created, ...items];
    notifyListeners();
    return created;
  }
}
