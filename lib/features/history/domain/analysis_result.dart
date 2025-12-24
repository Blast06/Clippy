class AnalysisResult {
  const AnalysisResult({
    required this.title,
    required this.summary,
    required this.tags,
  });

  final String title;
  final String summary;
  final List<String> tags;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      title: json['title'] as String? ?? 'AI Result',
      summary: json['summary'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((dynamic item) => item.toString())
          .toList(),
    );
  }
}
