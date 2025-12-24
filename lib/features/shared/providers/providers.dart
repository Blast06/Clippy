import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/data/clipboard_repository.dart';
import '../../history/data/clipboard_service.dart';
import '../../history/domain/analysis_result.dart';
import '../../history/domain/clipboard_item.dart';
import '../../history/domain/folder.dart';

final baseUrlProvider = StateProvider<String>((ref) {
  return 'https://api.example.com';
});

final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return ClipboardService(baseUrl: baseUrl);
});

final clipboardRepositoryProvider = Provider<ClipboardRepository>((ref) {
  final service = ref.watch(clipboardServiceProvider);
  return ClipboardRepository(service);
});

final clipboardItemsProvider = FutureProvider<List<ClipboardItem>>((ref) async {
  final repo = ref.watch(clipboardRepositoryProvider);
  return repo.fetchItems();
});

final favoritesProvider = FutureProvider<List<ClipboardItem>>((ref) async {
  final repo = ref.watch(clipboardRepositoryProvider);
  return repo.fetchFavorites();
});

final foldersProvider = FutureProvider<List<ClipboardFolder>>((ref) async {
  final repo = ref.watch(clipboardRepositoryProvider);
  return repo.fetchFolders();
});

final analyzerProvider = FutureProvider.family<AnalysisResult, String>((ref, text) async {
  final repo = ref.watch(clipboardRepositoryProvider);
  return repo.analyze(text);
});
