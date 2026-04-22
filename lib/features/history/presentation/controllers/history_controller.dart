import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../domain/clipboard_item.dart';

class HistoryController extends GetxController {
  HistoryController(this._state);

  final ClipboardStateController _state;

  RxList<ClipboardItem> get items => _state.items;
  RxBool get loading => _state.loading;

  @override
  void onInit() {
    super.onInit();
    _state.ensureLoaded();
  }

  List<ClipboardItem> search(String query) {
    return _state.search(query);
  }

  Future<void> addItem(String content) {
    return _state.addItem(content);
  }

  Future<void> toggleFavorite(String id) {
    return _state.toggleFavorite(id);
  }
}
