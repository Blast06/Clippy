import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/clipboard/presentation/bindings/clipboard_binding.dart';

class ClipboardApp extends StatelessWidget {
  const ClipboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clippy',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialBinding: ClipboardBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
