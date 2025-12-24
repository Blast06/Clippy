import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/providers/providers.dart';

class ClipboardApp extends StatelessWidget {
  const ClipboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clipboard AI Manager',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialBinding: ClipboardBinding(),
      home: const AppRouter(),
    );
  }
}
