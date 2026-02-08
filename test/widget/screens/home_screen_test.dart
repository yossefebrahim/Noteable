import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

Future<NotesViewModel> _buildVm() async {
  final repo = InMemoryNotesFeatureRepository();
  await repo.createNote(title: 'First', content: 'Body');
  await repo.createNote(title: 'Second', content: 'Content 2');
  final vm = NotesViewModel(
    getNotes: GetNotesUseCase(repo),
    deleteNote: DeleteNoteUseCase(repo),
    togglePin: TogglePinUseCase(repo),
    getFolders: GetFoldersUseCase(repo),
    createFolder: CreateFolderUseCase(repo),
    renameFolder: RenameFolderUseCase(repo),
    deleteFolder: DeleteFolderUseCase(repo),
    searchNotes: SearchNotesUseCase(repo),
    restoreNote: RestoreNoteUseCase(repo),
  );
  await vm.load();
  return vm;
}

Widget _app(NotesViewModel vm) {
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())]);
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('HomeScreen renders notes and new note button', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget);
  });

  testWidgets('HomeScreen pin button toggles tooltip', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    // Find all Pin tooltips (one for each note)
    expect(find.byTooltip('Pin'), findsWidgets);
    // Tap the first Pin button
    await tester.tap(find.byTooltip('Pin').first);
    await tester.pumpAndSettle();
    // The first note should now have Unpin tooltip
    expect(find.byTooltip('Unpin'), findsOneWidget);
    expect(find.byTooltip('Pin'), findsOneWidget);
  });

  testWidgets('HomeScreen delete button shows snackbar with undo', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    // Verify notes are visible
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    // Find all delete buttons
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsNWidgets(2));

    // Tap the first delete button
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verify snackbar appears
    expect(find.textContaining('deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Verify one note was removed
    expect(deleteButtons, findsOneWidget);
  });

  testWidgets('HomeScreen undo button restores deleted note', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    // Verify notes are visible
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    final initialNoteCount = find.byType(Card).evaluate().length;
    expect(initialNoteCount, 2);

    // Find all delete buttons
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verify one note was removed
    expect(find.byType(Card).evaluate().length, 1);
    expect(find.text('Undo'), findsOneWidget);

    // Tap the undo button
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // Verify note count is back to original
    expect(find.byType(Card).evaluate().length, initialNoteCount);

    // Verify snackbar is dismissed
    expect(find.text('Undo'), findsNothing);
  });
}
