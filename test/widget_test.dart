import 'package:flutter_test/flutter_test.dart';

import 'package:clipboard_ai_manager/app.dart';

void main() {
  testWidgets('app boots with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ClipboardApp());
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
