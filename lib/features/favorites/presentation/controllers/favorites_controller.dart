import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../../history/domain/clipboard_item.dart';

class FavoritesController extends GetxController {
  FavoritesController(this._state);

  final ClipboardStateController _state;

  RxBool get loading => _state.loading;

  List<ClipboardItem> get favorites =>
      _state.items.where((item) => item.isFavorite).toList();

  @override
  void onInit() {
    super.onInit();
    _state.ensureLoaded();
  }

  Future<void> toggleFavorite(String id) {
    return _state.toggleFavorite(id);
  }
}
