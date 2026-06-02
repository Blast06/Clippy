import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';

class SettingsController extends GetxController {
  SettingsController(this._state);

  final ClipboardStateController _state;

  RxString get baseUrl => _state.baseUrl;
  RxBool get backendEnabled => _state.backendEnabled;
  RxBool get localOnlyMode => _state.localOnlyMode;

  @override
  void onInit() {
    super.onInit();
    _state.ensureLoaded();
    _state.ensureSettingsLoaded();
  }

  Future<void> updateBaseUrl(String value) {
    return _state.updateBaseUrl(value);
  }

  Future<void> updateBackendEnabled(bool value) {
    return _state.updateBackendEnabled(value);
  }

  Future<void> updateLocalOnlyMode(bool value) {
    return _state.updateLocalOnlyMode(value);
  }

  Future<void> clearHistory() {
    return _state.clearHistory();
  }
}
