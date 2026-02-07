import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('SettingsScreen toggles dark mode', (tester) async {
    final app = AppProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(app.isDarkMode, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(app.isDarkMode, isTrue);
  });
}
