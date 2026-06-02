class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 15),
  });

  factory ApiConfig.fromEnvironment() {
    return const ApiConfig(
      baseUrl: String.fromEnvironment('CLIPPY_BACKEND_BASE_URL'),
    );
  }

  final String baseUrl;
  final Duration timeout;

  ApiConfig copyWith({
    String? baseUrl,
    Duration? timeout,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeout: timeout ?? this.timeout,
    );
  }
}
