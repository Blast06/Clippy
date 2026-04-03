import 'package:get/get.dart';

import '../../data/repositories/clipboard_repository.dart';
import '../../data/services/clipboard_api_service.dart';
import '../../data/services/clipboard_database_service.dart';
import '../controllers/clipboard_controller.dart';

class ClipboardBinding extends Bindings {
  ClipboardBinding({String baseUrl = 'https://api.example.com'})
      : _baseUrl = baseUrl;

  final String _baseUrl;

  @override
  void dependencies() {
    Get.lazyPut<ClipboardApiService>(
      () => ClipboardApiService(baseUrl: _baseUrl),
      fenix: true,
    );
    Get.lazyPut<ClipboardDatabaseService>(
      ClipboardDatabaseService.new,
      fenix: true,
    );
    Get.lazyPut<ClipboardRepository>(
      () => ClipboardRepository(
        Get.find<ClipboardDatabaseService>(),
        Get.find<ClipboardApiService>(),
      ),
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
