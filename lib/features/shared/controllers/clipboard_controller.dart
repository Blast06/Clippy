import 'package:get/get.dart';

import '../../history/data/clipboard_repository.dart';
import '../../history/domain/analysis_result.dart';
import '../../history/domain/clipboard_item.dart';
import '../../history/domain/folder.dart';

class ClipboardController extends GetxController {
  ClipboardController({required this.repository, String initialBaseUrl = 'https://api.example.com'})
      : baseUrl = initialBaseUrl.obs;

  final ClipboardRepository repository;
  final RxList<ClipboardItem> items = <ClipboardItem>[].obs;
  final RxList<ClipboardFolder> folders = <ClipboardFolder>[].obs;
  final RxString baseUrl;
  final RxBool loading = false.obs;

  List<ClipboardItem> get favorites => items.where((item) => item.isFavorite).toList();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    items.assignAll(await repository.fetchItems());
    folders.assignAll(await repository.fetchFolders());
    loading.value = false;
  }

  List<ClipboardItem> search(String query) {
    final lower = query.toLowerCase();
    return items
        .where(
          (item) => item.content.toLowerCase().contains(lower) ||
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
