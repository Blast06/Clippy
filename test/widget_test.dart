import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:clipboard_ai_manager/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('app boots with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ClipboardApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
