import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final http.Response r = await _api.get(_api.uri('/users'));
    final data = _api.decode(r);
    return _parse(
      'users',
      () => (data as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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
