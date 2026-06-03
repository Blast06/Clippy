import 'package:uuid/uuid.dart';

enum AiActionType {
  summarize,
  cleanText,
  translateToSpanish,
  translateToEnglish,
  rewriteFormal,
  rewriteCasual,
  classify,
  extractEntities,
}

extension AiActionTypeLabel on AiActionType {
  String get key {
    return switch (this) {
      AiActionType.summarize => 'summarize',
      AiActionType.cleanText => 'clean_text',
      AiActionType.translateToSpanish => 'translate_to_spanish',
      AiActionType.translateToEnglish => 'translate_to_english',
      AiActionType.rewriteFormal => 'rewrite_formal',
      AiActionType.rewriteCasual => 'rewrite_casual',
      AiActionType.classify => 'classify',
      AiActionType.extractEntities => 'extract_entities',
    };
  }

  String get label {
    return switch (this) {
      AiActionType.summarize => 'Summarize',
      AiActionType.cleanText => 'Clean text',
      AiActionType.translateToSpanish => 'Translate to Spanish',
      AiActionType.translateToEnglish => 'Translate to English',
      AiActionType.rewriteFormal => 'Rewrite formal',
      AiActionType.rewriteCasual => 'Rewrite casual',
      AiActionType.classify => 'Classify',
      AiActionType.extractEntities => 'Extract entities',
    };
  }

  String get instruction {
    return switch (this) {
      AiActionType.summarize => 'Summarize this clipboard text concisely.',
      AiActionType.cleanText =>
        'Clean up formatting, whitespace, and obvious text issues.',
      AiActionType.translateToSpanish =>
        'Translate this clipboard text to Spanish.',
      AiActionType.translateToEnglish =>
        'Translate this clipboard text to English.',
      AiActionType.rewriteFormal =>
        'Rewrite this clipboard text in a formal tone.',
      AiActionType.rewriteCasual =>
        'Rewrite this clipboard text in a casual tone.',
      AiActionType.classify => 'Classify this clipboard text.',
      AiActionType.extractEntities =>
        'Extract named entities, links, dates, people, places, and key values.',
    };
  }
}

class AiActionResult {
  AiActionResult({
    required this.itemId,
    required this.action,
    required this.input,
    required this.output,
    required this.createdAt,
  }) : id = const Uuid().v4();

  const AiActionResult.withId({
    required this.id,
    required this.itemId,
    required this.action,
    required this.input,
    required this.output,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final AiActionType action;
  final String input;
  final String output;
  final DateTime createdAt;
}
