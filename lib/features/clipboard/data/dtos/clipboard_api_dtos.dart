import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';

class ClipboardAnalyzeRequestDto {
  const ClipboardAnalyzeRequestDto({required this.text});

  final String text;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text};
  }
}

class ClipboardAnalyzeResponseDto {
  const ClipboardAnalyzeResponseDto({
    required this.title,
    required this.summary,
    required this.tags,
  });

  factory ClipboardAnalyzeResponseDto.fromJson(Map<String, dynamic> json) {
    return ClipboardAnalyzeResponseDto(
      title: json['title'] as String? ?? 'AI Result',
      summary: json['summary'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(growable: false),
    );
  }

  final String title;
  final String summary;
  final List<String> tags;

  AnalysisResult toDomain() {
    return AnalysisResult(
      title: title,
      summary: summary,
      tags: tags,
    );
  }
}

class ClipboardTransformRequestDto {
  const ClipboardTransformRequestDto({
    required this.text,
    required this.instruction,
  });

  final String text;
  final String instruction;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'instruction': instruction,
    };
  }
}

class ClipboardTransformResponseDto {
  const ClipboardTransformResponseDto({
    required this.text,
    this.summary,
  });

  factory ClipboardTransformResponseDto.fromJson(Map<String, dynamic> json) {
    return ClipboardTransformResponseDto(
      text: (json['text'] as String?) ?? (json['result'] as String?) ?? '',
      summary: json['summary'] as String?,
    );
  }

  final String text;
  final String? summary;
}

class ClipboardClassifyRequestDto {
  const ClipboardClassifyRequestDto({required this.text});

  final String text;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text};
  }
}

class ClipboardClassifyResponseDto {
  const ClipboardClassifyResponseDto({
    required this.type,
    required this.labels,
    this.confidence,
  });

  factory ClipboardClassifyResponseDto.fromJson(Map<String, dynamic> json) {
    return ClipboardClassifyResponseDto(
      type: _typeFromJson(json['type'] as String?),
      labels: (json['labels'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(growable: false),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  final ClipboardItemType type;
  final List<String> labels;
  final double? confidence;

  static ClipboardItemType _typeFromJson(String? value) {
    return ClipboardItemType.values.firstWhere(
      (ClipboardItemType type) => type.name == value,
      orElse: () => ClipboardItemType.unknown,
    );
  }
}
