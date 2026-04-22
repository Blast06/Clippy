import 'package:get/get.dart';

import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../history/presentation/controllers/ai_controller.dart';
import '../../../history/presentation/controllers/folders_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../data/repositories/clipboard_repository.dart';
import '../../data/services/clipboard_api_service.dart';
import '../../data/services/clipboard_database_service.dart';
import '../controllers/clipboard_state_controller.dart';

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
    Get.lazyPut<ClipboardStateController>(
      () => ClipboardStateController(
        repository: Get.find<ClipboardRepository>(),
        initialBaseUrl: _baseUrl,
      ),
      fenix: true,
    );
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<ClipboardStateController>()),
      fenix: true,
    );
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(Get.find<ClipboardStateController>()),
      fenix: true,
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(Get.find<ClipboardStateController>()),
      fenix: true,
    );
    Get.lazyPut<FoldersController>(
      () => FoldersController(Get.find<ClipboardStateController>()),
      fenix: true,
    );
    Get.lazyPut<AiController>(
      () => AiController(Get.find<ClipboardStateController>()),
      fenix: true,
    );
  }
}
