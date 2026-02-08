import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/screens/home/widgets/empty_notes_state.dart';

void main() {
  group('EmptyNotesState', () {
    testWidgets('renders title, subtitle, icon and action button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(),
          ),
        ),
      );

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Create your first note to get started.'), findsOneWidget);
      expect(find.byIcon(Icons.note_alt_outlined), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders first tip initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(),
          ),
        ),
      );

      expect(
        find.text('Press the + button to create your first note'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('action button calls onCreateTap callback', (tester) async {
      var callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(
              onCreateTap: () => callbackCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('New Note'), findsOneWidget);
      await tester.tap(find.text('New Note'));
      expect(callbackCalled, isTrue);
    });

    testWidgets('action button is disabled when onCreateTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders all tips in container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(),
          ),
        ),
      );

      // Verify the tip container exists
      expect(find.byType(Container), findsWidgets);

      // Verify the lightbulb icon exists
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('uses FilledButton for action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyNotesState(
              onCreateTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);
    });
  });
}
