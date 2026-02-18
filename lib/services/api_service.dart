// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/errors/lg_exceptions.dart';

/// Generic HTTP client for fetching data from external APIs.
///
/// Provides simple GET/POST with timeout, error handling, and JSON parsing.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  static const Duration _defaultTimeout = Duration(seconds: 15);

  /// Performs an HTTP GET request and returns the response body as a string.
  Future<String> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw LGException(
          'HTTP GET failed: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      return response.body;
    } on LGException {
      rethrow;
    } catch (e) {
      throw LGException('Network request failed: $url', e);
    }
  }

  /// Performs an HTTP GET and parses the response as JSON.
  Future<dynamic> getJson(
    String url, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final body = await get(url, headers: headers, timeout: timeout);
    try {
      return json.decode(body);
    } catch (e) {
      throw LGException('Failed to parse JSON from: $url', e);
    }
  }

  /// Performs an HTTP POST request with a JSON body.
  Future<String> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await _client
          .post(
            Uri.parse(url),
            headers: defaultHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw LGException(
          'HTTP POST failed: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      return response.body;
    } on LGException {
      rethrow;
    } catch (e) {
      throw LGException('Network request failed: $url', e);
    }
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
