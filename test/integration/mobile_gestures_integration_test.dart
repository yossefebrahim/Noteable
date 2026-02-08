import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile Gestures - End-to-End', () {
    late InMemoryNotesFeatureRepository repo;
    late NotesViewModel notesVm;
    late NoteEditorViewModel editorVm;

    setUp(() async {
      repo = InMemoryNotesFeatureRepository();
      notesVm = NotesViewModel(
        getNotes: GetNotesUseCase(repo),
        deleteNote: DeleteNoteUseCase(repo),
        togglePin: TogglePinUseCase(repo),
        getFolders: GetFoldersUseCase(repo),
        createFolder: CreateFolderUseCase(repo),
        renameFolder: RenameFolderUseCase(repo),
        deleteFolder: DeleteFolderUseCase(repo),
        searchNotes: SearchNotesUseCase(repo),
      );
      editorVm = NoteEditorViewModel(
        createNote: CreateNoteUseCase(repo),
        updateNote: UpdateNoteUseCase(repo),
        getNotes: GetNotesUseCase(repo),
      );
      await notesVm.load();
    });

    Widget _buildApp() {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        ],
      );
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notesVm),
          ChangeNotifierProvider.value(value: editorVm),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('Long-press on note shows contextual menu', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Test Note', content: 'Test content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note is displayed
      expect(find.text('Test Note'), findsOneWidget);

      // Find the note card and long-press it
      final noteCard = find.text('Test Note');
      await tester.longPress(noteCard.first);
      await tester.pumpAndSettle();

      // Verify contextual menu appears with all options
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Contextual menu - Pin/Unpin action works', (tester) async {
      // Create a test note
      await repo.createNote(title: 'Pinnable Note', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Long-press to show menu
      final noteCard = find.text('Pinnable Note');
      await tester.longPress(noteCard.first);
      await tester.pumpAndSettle();

      // Tap "Pin" option
      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();

      // Verify note is now pinned (shows pin emoji)
      expect(find.text('📌'), findsOneWidget);
    });

    testWidgets('Contextual menu - Delete action works', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Deletable Note', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note exists before deletion
      expect(find.text('Deletable Note'), findsOneWidget);

      // Long-press to show menu
      final noteCard = find.text('Deletable Note');
      await tester.longPress(noteCard.first);
      await tester.pumpAndSettle();

      // Tap "Delete" option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify note is deleted
      expect(find.text('Deletable Note'), findsNothing);
    });

    testWidgets('Contextual menu - Share action shows feedback', (tester) async {
      // Create a test note
      await repo.createNote(title: 'Shareable Note', content: 'Share this content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Long-press to show menu
      final noteCard = find.text('Shareable Note');
      await tester.longPress(noteCard.first);
      await tester.pumpAndSettle();

      // Tap "Share" option
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Verify share feedback is shown
      expect(find.text('Note copied to clipboard'), findsOneWidget);
    });

    testWidgets('Swipe left on note shows delete action', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Swipe Left Note', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note exists
      expect(find.text('Swipe Left Note'), findsOneWidget);

      // Swipe left on the note
      final noteCard = find.text('Swipe Left Note');
      await tester.drag(noteCard.first, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify delete confirmation dialog appears
      expect(find.text('Delete note?'), findsOneWidget);
    });

    testWidgets('Swipe right on note toggles pin status', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Swipe Right Note', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note is initially unpinned
      expect(find.text('📍'), findsOneWidget);

      // Swipe right on the note
      final noteCard = find.text('Swipe Right Note');
      await tester.drag(noteCard.first, const Offset(400, 0));
      await tester.pumpAndSettle();

      // Verify pin feedback is shown
      expect(find.text('Note pinned'), findsOneWidget);

      // Verify note is now pinned
      expect(find.text('📌'), findsOneWidget);
    });

    testWidgets('Swipe left and confirm delete removes note', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Delete Me', content: 'Content');
      await repo.createNote(title: 'Keep Me', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify both notes exist
      expect(find.text('Delete Me'), findsOneWidget);
      expect(find.text('Keep Me'), findsOneWidget);

      // Swipe left on "Delete Me" note
      final deleteNote = find.text('Delete Me');
      await tester.drag(deleteNote.first, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify "Delete Me" is gone but "Keep Me" remains
      expect(find.text('Delete Me'), findsNothing);
      expect(find.text('Keep Me'), findsOneWidget);
    });

    testWidgets('Multiple swipes work correctly', (tester) async {
      // Create multiple test notes
      await repo.createNote(title: 'First Note', content: 'Content 1');
      await repo.createNote(title: 'Second Note', content: 'Content 2');
      await repo.createNote(title: 'Third Note', content: 'Content 3');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Swipe right on first note to pin it
      await tester.drag(find.text('First Note'), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Verify first note is pinned
      expect(find.text('Note pinned'), findsOneWidget);

      // Swipe left on second note to delete it
      await tester.drag(find.text('Second Note'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify delete dialog appears
      expect(find.text('Delete note?'), findsOneWidget);

      // Cancel the deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify second note still exists
      expect(find.text('Second Note'), findsOneWidget);
    });

    testWidgets('Complete mobile workflow: Long press, swipe, actions', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Workflow Note', content: 'Test content for workflow');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Step 1: Long-press to show menu
      await tester.longPress(find.text('Workflow Note'));
      await tester.pumpAndSettle();
      expect(find.text('Pin'), findsOneWidget);

      // Close menu by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Step 2: Swipe right to pin
      await tester.drag(find.text('Workflow Note'), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Note pinned'), findsOneWidget);
      expect(find.text('📌'), findsOneWidget);

      // Step 3: Long-press again to verify menu shows "Unpin" now
      await tester.longPress(find.text('Workflow Note'));
      await tester.pumpAndSettle();
      expect(find.text('Unpin'), findsOneWidget);

      // Close menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Step 4: Swipe right again to unpin
      await tester.drag(find.text('Workflow Note'), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Note unpinned'), findsOneWidget);

      // Step 5: Swipe left to delete
      await tester.drag(find.text('Workflow Note'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify delete dialog
      expect(find.text('Delete note?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify note is deleted
      expect(find.text('Workflow Note'), findsNothing);
    });

    testWidgets('Contextual menu shows correct pin state', (tester) async {
      // Create one pinned and one unpinned note
      final pinnedNote = await repo.createNote(title: 'Pinned Note', content: 'Content');
      await repo.createNote(title: 'Unpinned Note', content: 'Content');
      await repo.togglePin(pinnedNote.id); // Pin the first note
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Long-press on pinned note
      await tester.longPress(find.text('Pinned Note'));
      await tester.pumpAndSettle();
      expect(find.text('Unpin'), findsOneWidget);

      // Close menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Long-press on unpinned note
      await tester.longPress(find.text('Unpinned Note'));
      await tester.pumpAndSettle();
      expect(find.text('Pin'), findsOneWidget);
    });

    testWidgets('Move to folder option handles no folders case', (tester) async {
      // Create a test note without any folders
      await repo.createNote(title: 'Orphan Note', content: 'Content');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Long-press to show menu
      await tester.longPress(find.text('Orphan Note'));
      await tester.pumpAndSettle();

      // Tap "Move to folder"
      await tester.tap(find.text('Move to folder'));
      await tester.pumpAndSettle();

      // Verify "no folders" message
      expect(find.text('No folders available. Create a folder first.'), findsOneWidget);
    });

    testWidgets('Empty state shows appropriate message', (tester) async {
      // Don't create any notes
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No notes yet. Tap "New note"'), findsOneWidget);
    });
  });
}
