import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/widgets/app_button.dart';

void main() {
  testWidgets('AppButton triggers onPressed and shows loader', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Save', onPressed: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(tapped, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Save', isLoading: true),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
