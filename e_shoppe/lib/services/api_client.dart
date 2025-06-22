import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:e_shoppe/config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _jwt;

  // Call this after successful login
  set authToken(String token) => _jwt = token;
  void clearToken() => _jwt = null;

  Future<dynamic> get(String path) async {
    final res = await _client.get(_uri(path), headers: _headers);
    _check(res);
    return _decode(res);
  }

  Future<dynamic> post(String path, Map body) async {
    final res = await _client.post(_uri(path),
        headers: _headers, body: jsonEncode(body));
    _check(res);
    return _decode(res);
  }

  Future<dynamic> patch(String path, Map body) async {
    final res = await _client.patch(_uri(path),
        headers: _headers, body: jsonEncode(body));
    _check(res);
    return _decode(res);
  }

  Uri _uri(String path) => Uri.parse('$kApiBase$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
      };

  void _check(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
  }

  dynamic _decode(http.Response r) {
    if (r.body.isEmpty) return null;
    try {
      return jsonDecode(r.body);
    } catch (_) {
      // Not JSON – return raw string.
      return r.body;
    }
  }
}

/// Global provider
final apiProvider = Provider<ApiClient>((_) => ApiClient());
