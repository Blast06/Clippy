import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../history/domain/analysis_result.dart';

class ClipboardApiService {
  ClipboardApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  String baseUrl;
  final http.Client _client;

  Future<AnalysisResult> analyze(String text) async {
    final uri = Uri.parse('$baseUrl/clipboard/analyze');
    final response = await _client.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'text': text}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AnalysisResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    return const AnalysisResult(
      title: 'Offline analysis',
      summary: 'No network response. Showing a sample summary for now.',
      tags: <String>['offline', 'sample'],
    );
  }

  void updateBaseUrl(String value) {
    baseUrl = value;
  }
}
