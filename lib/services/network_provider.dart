import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class ProxyAwareHttpClient extends IOClient {
  ProxyAwareHttpClient()
      : super(HttpClient()..findProxy = HttpClient.findProxyFromEnvironment);
}

class NetworkProvider {
  NetworkProvider()
      : _client = ProxyAwareHttpClient(),
        _defaultHeaders = {
          'Content-Type': 'application/json',
          'Authorization': ''
        };

  static const String baseUrl = 'localhost';
  static const int port = 6000;

  // The Dio instance for all of the application
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  void setAuthHeader(String authToken) {
    _defaultHeaders['Authorization'] = authToken;
  }

  Uri _createUri(String requestUri) {
    return Uri(scheme: 'http', host: baseUrl, port: port, path: requestUri);
  }

  Future<Response> get(String requestUri) async {
    return await _client.get(_createUri(requestUri), headers: _defaultHeaders);
  }

  Future<Response> post(String requestUri, String jsonBody) async {
    return await _client.post(_createUri(requestUri),
        body: jsonBody, headers: _defaultHeaders);
  }

  Future<Response> put(String requestUri, [String? jsonBody]) async {
    return await _client.put(_createUri(requestUri),
        body: jsonBody, headers: _defaultHeaders);
  }

  Future<Response> delete(String requestUri, [String? body]) async {
    return await _client.delete(_createUri(requestUri),
        headers: _defaultHeaders, body: body);
  }
}
