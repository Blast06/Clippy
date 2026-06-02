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
  final RxBool backendEnabled = false.obs;
  final RxBool localOnlyMode = true.obs;
  final RxBool loading = false.obs;
  final RxBool readingClipboard = false.obs;

  bool _hasLoaded = false;
  bool _settingsLoaded = false;

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

  Future<void> ensureSettingsLoaded() async {
    if (_settingsLoaded) {
      return;
    }
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final String? savedBackendEnabled = await repository.fetchSetting(
      ClipboardRepository.backendEnabledKey,
    );
    final String? savedLocalOnlyMode = await repository.fetchSetting(
      ClipboardRepository.localOnlyModeKey,
    );
    final String? savedBaseUrl = await repository.fetchSetting(
      ClipboardRepository.backendBaseUrlKey,
    );

    backendEnabled.value =
        _settingToBool(savedBackendEnabled, defaultValue: false);
    localOnlyMode.value =
        _settingToBool(savedLocalOnlyMode, defaultValue: true);

    if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
      await updateBaseUrl(savedBaseUrl, persist: false);
    }

    _settingsLoaded = true;
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

  Future<void> clearHistory() async {
    await repository.clearHistory();
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
    if (localOnlyMode.value || !backendEnabled.value) {
      return Future<AnalysisResult>.value(
        const AnalysisResult(
          title: 'Local-only mode',
          summary: 'Backend analysis is disabled in Settings.',
          tags: <String>['local-only'],
        ),
      );
    }

    return repository.analyze(text);
  }

  Future<void> updateBackendEnabled(bool value) async {
    backendEnabled.value = value;
    if (value) {
      localOnlyMode.value = false;
      await repository.saveSetting(
        ClipboardRepository.localOnlyModeKey,
        _boolToSetting(false),
      );
    }
    await repository.saveSetting(
      ClipboardRepository.backendEnabledKey,
      _boolToSetting(value),
    );
  }

  Future<void> updateLocalOnlyMode(bool value) async {
    localOnlyMode.value = value;
    if (value) {
      backendEnabled.value = false;
      await repository.saveSetting(
        ClipboardRepository.backendEnabledKey,
        _boolToSetting(false),
      );
    }
    await repository.saveSetting(
      ClipboardRepository.localOnlyModeKey,
      _boolToSetting(value),
    );
  }

  Future<void> updateBaseUrl(String value, {bool persist = true}) async {
    baseUrl.value = value;
    repository.updateBaseUrl(value);
    if (persist) {
      await repository.saveSetting(
        ClipboardRepository.backendBaseUrlKey,
        value,
      );
    }
  }

  bool _settingToBool(String? value, {required bool defaultValue}) {
    if (value == null) {
      return defaultValue;
    }
    return value == 'true';
  }

  String _boolToSetting(bool value) {
    return value.toString();
  }
}
