import 'package:get/get.dart';

import '../../history/data/clipboard_repository.dart';
import '../../history/data/clipboard_service.dart';
import '../controllers/clipboard_controller.dart';

/// Registers GetX dependencies for clipboard features.
class ClipboardBinding extends Bindings {
  ClipboardBinding({String baseUrl = 'https://api.example.com'})
      : _baseUrl = baseUrl;

  final String _baseUrl;

  @override
  void dependencies() {
    Get.lazyPut<ClipboardService>(
      () => ClipboardService(baseUrl: _baseUrl),
      fenix: true,
    );
    Get.lazyPut<ClipboardRepository>(
      () => ClipboardRepository(Get.find<ClipboardService>()),
      fenix: true,
    );
    Get.lazyPut<ClipboardController>(
      () => ClipboardController(
        repository: Get.find<ClipboardRepository>(),
        initialBaseUrl: _baseUrl,
      ),
      fenix: true,
    );
  }
}
