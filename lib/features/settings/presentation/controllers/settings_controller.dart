import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';

class SettingsController extends GetxController {
  SettingsController(this._state);

  final ClipboardStateController _state;
  final RxBool syncEnabled = false.obs;
  final RxBool biometricEnabled = false.obs;

  RxString get baseUrl => _state.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _state.ensureLoaded();
  }

  void updateBaseUrl(String value) {
    _state.updateBaseUrl(value);
  }

  void updateSyncEnabled(bool value) {
    syncEnabled.value = value;
  }

  void updateBiometricEnabled(bool value) {
    biometricEnabled.value = value;
  }
}
