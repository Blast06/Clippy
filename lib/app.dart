import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/history/data/clipboard_repository.dart';
import 'features/history/data/clipboard_service.dart';
import 'features/shared/controllers/clipboard_controller.dart';

class ClipboardApp extends StatelessWidget {
  ClipboardApp({super.key}) {
    final service = ClipboardService(baseUrl: 'https://api.example.com');
    final repository = ClipboardRepository(service);
    Get.put(ClipboardController(repository: repository));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clipboard AI Manager',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
    );
  }
}
