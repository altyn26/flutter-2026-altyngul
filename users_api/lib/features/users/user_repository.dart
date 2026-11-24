import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<UsersResult> getAll() async {
    try {
      final http.Response r = await _api.get(_api.uri('/users'));
      final data = _api.decode(r);
      final fresh = _parse(
        'users',
        () => (data as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow; // честный экран Offline
      return (items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final http.Response r = await _api.get(_api.uri('/users/$id'));
    final data = _api.decode(r);
    return _parse(
      'users/$id',
      () => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> create(User draft) async {
    final body = draft.toJson()..remove('id'); // the server assigns id
    final http.Response r = await _api.post(
      _api.uri('/users'),
      body: jsonEncode(body),
    );
    if (r.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${r.statusCode}',
      );
    }
    final data = _api.decode(r);
    return _parse(
      'POST users',
      () => User.fromJson(data as Map<String, dynamic>),
    );
  }

  /// A failed cast or parse inside fromJson becomes our exception.
  T _parse<T>(String where, T Function() read) {
    try {
      return read();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
