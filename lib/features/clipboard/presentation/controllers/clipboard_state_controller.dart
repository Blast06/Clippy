import 'package:get/get.dart';

import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';
import '../../../history/domain/folder.dart';
import '../../data/repositories/clipboard_repository.dart';

class ClipboardStateController extends GetxController {
  ClipboardStateController({
    required this.repository,
    String initialBaseUrl = 'https://api.example.com',
  }) : baseUrl = initialBaseUrl.obs;

  final ClipboardRepository repository;
  final RxList<ClipboardItem> items = <ClipboardItem>[].obs;
  final RxList<ClipboardFolder> folders = <ClipboardFolder>[].obs;
  final RxString baseUrl;
  final RxBool loading = false.obs;

  bool _hasLoaded = false;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || loading.value) {
      return;
    }
    await loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    items.assignAll(await repository.fetchItems());
    folders.assignAll(await repository.fetchFolders());
    loading.value = false;
    _hasLoaded = true;
  }

  List<ClipboardItem> search(String query) {
    final lower = query.toLowerCase();
    return items
        .where(
          (item) =>
              item.content.toLowerCase().contains(lower) ||
              item.tags.any((tag) => tag.toLowerCase().contains(lower)),
        )
        .toList();
  }

  Future<void> addItem(String content) async {
    await repository.addItem(content);
    await loadData();
  }

  Future<void> toggleFavorite(String id) async {
    await repository.toggleFavorite(id);
    await loadData();
  }

  Future<AnalysisResult> analyze(String text) {
    return repository.analyze(text);
  }

  void updateBaseUrl(String value) {
    baseUrl.value = value;
    repository.updateBaseUrl(value);
  }
}
