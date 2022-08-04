import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response, StreamedResponse;
import 'package:http_parser/http_parser.dart';

import 'auth.dart';

final otherApiProvider = Provider((ref) {
  return BackendAPINew("http://10.0.2.2:5000/api/");
});

class BackendAPINew {
  final String _baseUrl;

  BackendAPINew(String baseUrl) : _baseUrl = baseUrl;

  Uri _getUri(endpoint) {
    return Uri.parse('$_baseUrl$endpoint');
  }

  Future<Response> _post(String endpoint,
      {Map<String, String>? headers, Object? body}) {
    return http.post(_getUri(endpoint), headers: headers, body: body);
  }

  Future<Response> _get(String endpoint, {Map<String, String>? headers}) {
    return http.get(_getUri(endpoint), headers: headers);
  }

  Future<Response> update(String userId) async {
    return _get('update/$userId');
  }

  Future<Response> getChatToken(String userId) async {
    return _get('chat-token/$userId');
  }
}