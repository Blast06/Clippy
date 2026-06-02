import '../../../../core/api/api_client.dart';
import '../../../history/domain/analysis_result.dart';
import '../dtos/clipboard_api_dtos.dart';

class ClipboardApiService {
  ClipboardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const String analyzePath = '/webhook/clipboard/analyze';
  static const String transformPath = '/webhook/clipboard/transform';
  static const String classifyPath = '/webhook/clipboard/classify';

  final ApiClient _apiClient;

  Future<AnalysisResult> analyze(String text) async {
    final response = await _apiClient.postJson(
      path: analyzePath,
      body: ClipboardAnalyzeRequestDto(text: text).toJson(),
    );
    return ClipboardAnalyzeResponseDto.fromJson(response).toDomain();
  }

  Future<ClipboardTransformResponseDto> transform({
    required String text,
    required String instruction,
  }) async {
    final response = await _apiClient.postJson(
      path: transformPath,
      body: ClipboardTransformRequestDto(
        text: text,
        instruction: instruction,
      ).toJson(),
    );
    return ClipboardTransformResponseDto.fromJson(response);
  }

  Future<ClipboardClassifyResponseDto> classify(String text) async {
    final response = await _apiClient.postJson(
      path: classifyPath,
      body: ClipboardClassifyRequestDto(text: text).toJson(),
    );
    return ClipboardClassifyResponseDto.fromJson(response);
  }

  void updateBaseUrl(String value) {
    _apiClient.updateBaseUrl(value);
  }
}
