import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/note_provider.dart';
import 'package:noteable_app/presentation/widgets/note_card.dart';

void main() {
  testWidgets('NoteCard renders and pin tap works', (tester) async {
    var pinTapped = false;
    final note = NoteItem(
      id: '1',
      title: 'Title',
      content: 'Body',
      updatedAt: DateTime.now(),
      isPinned: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCard(
            note: note,
            onPinTap: () => pinTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(pinTapped, isTrue);
  });
}
