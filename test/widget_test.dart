import 'package:flutter_test/flutter_test.dart';
import 'package:clipboard_ai_manager/core/routes/app_router.dart';
import 'package:clipboard_ai_manager/features/clipboard/data/repositories/clipboard_repository.dart';
import 'package:clipboard_ai_manager/features/clipboard/data/services/clipboard_api_service.dart';
import 'package:clipboard_ai_manager/features/clipboard/data/services/clipboard_database_service.dart';
import 'package:clipboard_ai_manager/features/clipboard/presentation/controllers/clipboard_state_controller.dart';
import 'package:clipboard_ai_manager/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:clipboard_ai_manager/features/history/domain/analysis_result.dart';
import 'package:clipboard_ai_manager/features/history/presentation/controllers/ai_controller.dart';
import 'package:clipboard_ai_manager/features/history/presentation/controllers/folders_controller.dart';
import 'package:clipboard_ai_manager/features/history/presentation/controllers/history_controller.dart';
import 'package:clipboard_ai_manager/features/settings/presentation/controllers/settings_controller.dart';
import 'package:get/get.dart';

class _TestClipboardDatabaseService extends ClipboardDatabaseService {
  @override
  Future<List<Map<String, Object?>>> fetchItems() async =>
      <Map<String, Object?>>[];

  @override
  Future<List<Map<String, Object?>>> fetchFolders() async =>
      <Map<String, Object?>>[];

  @override
  Future<void> insertItem(Map<String, Object?> values) async {}

  @override
  Future<void> updateItemFavorite({
    required String id,
    required bool isFavorite,
  }) async {}

  @override
  Future<Map<String, Object?>?> fetchItemById(String id) async => null;

  @override
  Future<void> upsertFolder(Map<String, Object?> values) async {}
}

class _TestClipboardApiService extends ClipboardApiService {
  _TestClipboardApiService() : super(baseUrl: 'https://example.test');

  @override
  Future<AnalysisResult> analyze(String text) async => const AnalysisResult(
        title: 'Test',
        summary: 'Test',
        tags: <String>[],
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    final ClipboardRepository repository = ClipboardRepository(
      _TestClipboardDatabaseService(),
      _TestClipboardApiService(),
    );
    Get.put<ClipboardStateController>(
      ClipboardStateController(repository: repository),
    );
    Get.put<HistoryController>(
      HistoryController(Get.find<ClipboardStateController>()),
    );
    Get.put<FavoritesController>(
      FavoritesController(Get.find<ClipboardStateController>()),
    );
    Get.put<SettingsController>(
      SettingsController(Get.find<ClipboardStateController>()),
    );
    Get.put<FoldersController>(
      FoldersController(Get.find<ClipboardStateController>()),
    );
    Get.put<AiController>(
      AiController(Get.find<ClipboardStateController>()),
    );
  });

  tearDown(Get.reset);

  testWidgets('router shows bottom navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: AppRouter()));
    await tester.pump();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
