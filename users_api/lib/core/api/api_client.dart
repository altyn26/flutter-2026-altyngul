import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  static const _timeout = Duration(seconds: 10);

  /// Headers live in one place. The token is added here and nowhere else.
  Future<Map<String, String>> _headers() async {
    final token = await _store.readToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Addresses are always built with Uri.https, never by concatenation.
  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  Future<http.Response> get(Uri url) =>
      _run(() async => _client.get(url, headers: await _headers()));

  Future<http.Response> post(Uri url, {required String body}) => _run(
    () async => _client.post(
      url,
      headers: {...await _headers(), 'Content-Type': 'application/json'},
      body: body,
    ),
  );

  /// Public entry to the private decoder.
  dynamic decode(http.Response r) => _decode(r);

  Future<http.Response> _run(Future<http.Response> Function() call) async {
    final r = await _send(call);
    _check(r); // status first, body later — every time
    return r;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(_timeout);
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url.path} → ${r.statusCode}',
          name: 'api',
        );
      }
      return r;
    } on SocketException catch (e) {
      debugPrint('api: SocketException $e');
      throw const NoConnectionException();
    } on TimeoutException catch (e) {
      debugPrint('api: TimeoutException $e');
      throw const NoConnectionException();
    } on http.ClientException catch (e) {
      debugPrint('api: ClientException $e');
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    switch (r.statusCode) {
      case 401:
        throw const UnauthorizedException();
      case 404:
        throw const NotFoundException();
      case >= 500:
        throw ServerException(r.statusCode);
      case >= 400:
        throw BadResponseException('HTTP ${r.statusCode}');
    }
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('${r.request?.url.path}: $e');
    }
  }
}
