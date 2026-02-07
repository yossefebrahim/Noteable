import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/note_detail_provider.dart';
import 'package:noteable_app/presentation/providers/note_provider.dart';
import 'package:noteable_app/presentation/screens/note_detail/note_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('NoteDetailScreen creates and saves note', (tester) async {
    final listVm = NoteListViewModel();
    final detailVm = NoteDetailViewModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: listVm),
          ChangeNotifierProvider.value(value: detailVm),
        ],
        child: const MaterialApp(home: NoteDetailScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'My Note');
    await tester.enterText(find.byType(TextField).last, 'Body');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(listVm.notes.any((n) => n.title == 'My Note'), isTrue);
  });
}
