import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class ClipboardApp extends StatelessWidget {
  const ClipboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Clipboard AI Manager',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        home: const AppRouter(),
      ),
    );
  }
}
