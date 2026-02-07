import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField accepts input and calls onChanged', (tester) async {
    String value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            hintText: 'Type here',
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    expect(value, 'hello');
    expect(find.text('Type here'), findsOneWidget);
  });
}
