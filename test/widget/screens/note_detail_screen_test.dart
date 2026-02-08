import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/note_detail/note_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('NoteDetailScreen creates and saves note', (tester) async {
    final repo = InMemoryNotesFeatureRepository();
    final editorVm = NoteEditorViewModel(
      createNote: CreateNoteUseCase(repo),
      updateNote: UpdateNoteUseCase(repo),
      getNotes: GetNotesUseCase(repo),
    );
    final notesVm = NotesViewModel(
      getNotes: GetNotesUseCase(repo),
      deleteNote: DeleteNoteUseCase(repo),
      togglePin: TogglePinUseCase(repo),
      getFolders: GetFoldersUseCase(repo),
      createFolder: CreateFolderUseCase(repo),
      renameFolder: RenameFolderUseCase(repo),
      deleteFolder: DeleteFolderUseCase(repo),
      searchNotes: SearchNotesUseCase(repo),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NoteEditorViewModel>.value(value: editorVm),
          ChangeNotifierProvider<NotesViewModel>.value(value: notesVm),
        ],
        child: const MaterialApp(home: NoteDetailScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Find text fields using DebouncedTextField type
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    // Enter title
    await tester.enterText(textFields.at(0), 'My Note');
    await tester.pumpAndSettle();

    // Enter content
    await tester.enterText(textFields.at(1), 'Body');
    await tester.pumpAndSettle();

    // Wait for debounce delay (300ms default)
    await tester.pump(const Duration(milliseconds: 400));

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify note was saved
    await notesVm.refreshNotes();
    expect(notesVm.notes.any((n) => n.title == 'My Note'), isTrue);
  });
}
