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

  static const String baseUrl = 'localhost:6000/api';

  // The Dio instance for all of the application
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  void setAuthHeader(String authToken) {
    _defaultHeaders['Authorization'] = authToken;
  }

  Future<Response> get(String requestUri) async {
    return await _client.get(Uri(host: baseUrl, path: requestUri),
        headers: _defaultHeaders);
  }

  Future<Response> post(String requestUri, String jsonBody) async {
    return await _client.post(Uri(host: baseUrl, path: requestUri),
        body: jsonBody, headers: _defaultHeaders);
  }

  Future<Response> put(String requestUri, [String? jsonBody]) async {
    return await _client.put(Uri(host: baseUrl, path: requestUri),
        body: jsonBody, headers: _defaultHeaders);
  }

  Future<Response> delete(String requestUri) async {
    return await _client.delete(Uri(host: baseUrl, path: requestUri),
        headers: _defaultHeaders);
  }

  // Leave code for if we go back to using Dio
  /*
  void setDefaultHeaders() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      ..._dio.options.headers,
      'content-type': 'application/json',
    };
    _dio.options.contentType = 'application/json';
    _dio.options.setRequestContentTypeWhenNoPayload = false;
  }

  void setAuthHeader(String authToken) {
    _dio.options.headers = {
      ..._dio.options.headers,
      'authorization': 'Bearer $authToken',
    };
  }*/
}
