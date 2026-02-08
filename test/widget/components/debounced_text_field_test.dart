import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/widgets/debounced_text_field.dart';

void main() {
  group('DebouncedTextField', () {
    testWidgets('accepts input and displays hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
            ),
          ),
        ),
      );

      expect(find.text('Type here'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onChanged after debounce delay', (tester) async {
      String? value;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      expect(value, isNull); // Should not be called immediately

      // Wait for default debounce delay (300ms)
      await tester.pump(const Duration(milliseconds: 350));

      expect(value, 'hello');
    });

    testWidgets('uses custom debounce delay', (tester) async {
      String? value;
      const customDelay = Duration(milliseconds: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
              debounceDelay: customDelay,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      expect(value, isNull);

      // Wait less than custom delay - should not trigger yet
      await tester.pump(const Duration(milliseconds: 50));
      expect(value, isNull);

      // Wait for custom delay
      await tester.pump(customDelay);
      expect(value, 'hello');
    });

    testWidgets('rapid input only calls onChanged once after pause',
        (tester) async {
      int callCount = 0;
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
              onChanged: (v) {
                callCount++;
                lastValue = v;
              },
            ),
          ),
        ),
      );

      // Simulate rapid typing
      await tester.enterText(find.byType(TextField), 'h');
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.enterText(find.byType(TextField), 'he');
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.enterText(find.byType(TextField), 'hel');
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.enterText(find.byType(TextField), 'hell');
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      // Wait for debounce delay
      await tester.pump(const Duration(milliseconds: 300));

      expect(callCount, 1);
      expect(lastValue, 'hello');
    });

    testWidgets('uses custom controller when provided', (tester) async {
      final controller = TextEditingController(text: 'initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              controller: controller,
              hintText: 'Type here',
            ),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
      expect(find.text('Type here'), findsOneWidget);
    });

    testWidgets('respects maxLines parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
              maxLines: 5,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('displays prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('handles onChanged null safely', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebouncedTextField(
              hintText: 'Type here',
            ),
          ),
        ),
      );

      // Should not throw when onChanged is null
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Type here'), findsOneWidget);
    });
  });
}
