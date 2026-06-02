import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';
import '../../../history/domain/folder.dart';
import '../../data/repositories/clipboard_repository.dart';

enum ClipboardReadResult { added, duplicate, empty }

class ClipboardStateController extends GetxController
    with WidgetsBindingObserver {
  ClipboardStateController({
    required this.repository,
    String initialBaseUrl = 'https://api.example.com',
  }) : baseUrl = initialBaseUrl.obs;

  final ClipboardRepository repository;
  final RxList<ClipboardItem> items = <ClipboardItem>[].obs;
  final RxList<ClipboardFolder> folders = <ClipboardFolder>[].obs;
  final RxString baseUrl;
  final RxBool loading = false.obs;
  final RxBool readingClipboard = false.obs;

  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      readSystemClipboard();
    }
  }

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

  Future<ClipboardReadResult> readSystemClipboard() async {
    if (readingClipboard.value) {
      return ClipboardReadResult.empty;
    }

    readingClipboard.value = true;
    try {
      await ensureLoaded();
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String content = data?.text?.trim() ?? '';
      if (content.isEmpty) {
        return ClipboardReadResult.empty;
      }

      if (await repository.containsContent(content)) {
        return ClipboardReadResult.duplicate;
      }

      await repository.addItem(content);
      await loadData();
      return ClipboardReadResult.added;
    } finally {
      readingClipboard.value = false;
    }
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
