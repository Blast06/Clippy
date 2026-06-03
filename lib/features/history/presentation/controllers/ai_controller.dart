import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../domain/ai_action_result.dart';
import '../../domain/analysis_result.dart';
import '../../domain/clipboard_item.dart';

class AiController extends GetxController {
  AiController(this._state);

  final ClipboardStateController _state;
  final RxList<AiActionResult> results = <AiActionResult>[].obs;
  final Rxn<AiActionType> runningAction = Rxn<AiActionType>();
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  bool get isRunning => runningAction.value != null;
  bool get canUseBackend => _state.canUseBackend;

  Future<AnalysisResult> analyze(String text) {
    return _state.analyze(text);
  }

  @override
  void onInit() {
    super.onInit();
    _state.ensureSettingsLoaded();
  }

  Future<void> loadResults(String itemId) async {
    results.clear();
    results.assignAll(await _state.fetchAiActionResults(itemId));
  }

  Future<void> runAction({
    required ClipboardItem item,
    required AiActionType action,
  }) async {
    if (runningAction.value != null) {
      return;
    }

    clearMessages();
    runningAction.value = action;
    try {
      final AiActionResult result = await _state.runAiAction(
        item: item,
        action: action,
      );
      results.insert(0, result);
      successMessage.value = '${action.label} complete. Result saved locally.';
    } catch (error) {
      errorMessage.value = _messageForError(error);
    } finally {
      runningAction.value = null;
    }
  }

  Future<void> copyResult(AiActionResult result) {
    return Clipboard.setData(ClipboardData(text: result.output));
  }

  Future<void> saveAsSnippet(AiActionResult result) {
    return _state.addItem(result.output);
  }

  Future<void> replaceOriginal({
    required ClipboardItem item,
    required AiActionResult result,
  }) {
    return _state.replaceItemContent(id: item.id, content: result.output);
  }

  void clearError() {
    errorMessage.value = '';
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  String _messageForError(Object error) {
    if (error is StateError) {
      return error.message;
    }
    return 'AI action failed. Check backend settings and try again.';
  }
}
