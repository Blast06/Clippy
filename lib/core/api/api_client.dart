import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required ApiConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client();

  ApiConfig _config;
  final http.Client _httpClient;

  String get baseUrl => _config.baseUrl;

  void updateConfig(ApiConfig config) {
    _config = config;
  }

  void updateBaseUrl(String value) {
    _config = _config.copyWith(baseUrl: value);
  }

  Future<Map<String, dynamic>> postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final Uri uri = _buildUri(path);

    try {
      final http.Response response = await _httpClient
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_config.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          type: ApiExceptionType.http,
          statusCode: response.statusCode,
          message: _errorMessage(response.body),
        );
      }

      return _decodeObject(response.body);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(
        type: ApiExceptionType.timeout,
        message: 'Backend request timed out.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw ApiException(
        type: ApiExceptionType.decoding,
        message: 'Backend returned invalid JSON.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        type: ApiExceptionType.network,
        message: 'Backend request failed.',
        cause: error,
      );
    }
  }

  Uri _buildUri(String path) {
    final String trimmedBaseUrl = _config.baseUrl.trim();
    if (trimmedBaseUrl.isEmpty) {
      throw const ApiException(
        type: ApiExceptionType.configuration,
        message: 'Backend base URL is not configured.',
      );
    }

    final Uri? baseUri = Uri.tryParse(trimmedBaseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const ApiException(
        type: ApiExceptionType.configuration,
        message: 'Backend base URL is invalid.',
      );
    }

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.replace(
      pathSegments: <String>[
        ...baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        ...normalizedPath.split('/').where((segment) => segment.isNotEmpty),
      ],
    );
  }

  Map<String, dynamic> _decodeObject(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const ApiException(
      type: ApiExceptionType.decoding,
      message: 'Backend response must be a JSON object.',
    );
  }

  String _errorMessage(String body) {
    try {
      final Map<String, dynamic> decoded = _decodeObject(body);
      return (decoded['message'] as String?) ??
          (decoded['error'] as String?) ??
          'Backend request failed.';
    } catch (_) {
      return body.isEmpty ? 'Backend request failed.' : body;
    }
  }
}
