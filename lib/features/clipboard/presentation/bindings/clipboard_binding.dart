import 'package:get/get.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
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
  ClipboardBinding({ApiConfig? config})
      : _config = config ?? ApiConfig.fromEnvironment();

  final ApiConfig _config;

  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(
      () => ApiClient(config: _config),
      fenix: true,
    );
    Get.lazyPut<ClipboardApiService>(
      () => ClipboardApiService(apiClient: Get.find<ApiClient>()),
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
        initialBaseUrl: _config.baseUrl,
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
