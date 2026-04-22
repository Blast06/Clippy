import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../domain/folder.dart';

class FoldersController extends GetxController {
  FoldersController(this._state);

  final ClipboardStateController _state;

  RxList<ClipboardFolder> get folders => _state.folders;
  RxBool get loading => _state.loading;

  @override
  void onInit() {
    super.onInit();
    _state.ensureLoaded();
  }
}
