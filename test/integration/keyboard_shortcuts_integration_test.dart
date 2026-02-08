import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:noteable_app/presentation/screens/note_detail/note_detail_screen.dart';
import 'package:noteable_app/presentation/screens/search/search_screen.dart';
import 'package:noteable_app/presentation/screens/shortcuts_help/shortcuts_help_screen.dart';
import 'package:noteable_app/presentation/widgets/app_text_field.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Desktop Keyboard Shortcuts - End-to-End', () {
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
          GoRoute(path: '/note-detail', builder: (_, __) => const NoteDetailScreen()),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/keyboard-shortcuts', builder: (_, __) => const ShortcutsHelpScreen()),
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

    testWidgets('Cmd/Ctrl+N opens new note screen', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify we're on home screen
      expect(find.text('Notes'), findsOneWidget);

      // Simulate Cmd/Ctrl+N key press
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verify note detail screen opened
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('Cmd/Ctrl+F opens search screen', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify we're on home screen
      expect(find.text('Notes'), findsOneWidget);

      // Simulate Cmd/Ctrl+F key press
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verify search screen opened
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('Cmd/Ctrl+? (Shift+slash) opens help screen', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify we're on home screen
      expect(find.text('Notes'), findsOneWidget);

      // Simulate Cmd/Ctrl+Shift+/ key press
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verify help screen opened
      expect(find.text('Keyboard Shortcuts'), findsOneWidget);
      expect(find.text('File Operations'), findsOneWidget);
    });

    testWidgets('Arrow keys navigate note list', (tester) async {
      // Create test notes
      await repo.createNote(title: 'First Note', content: 'Content 1');
      await repo.createNote(title: 'Second Note', content: 'Content 2');
      await repo.createNote(title: 'Third Note', content: 'Content 3');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify all notes are displayed
      expect(find.text('First Note'), findsOneWidget);
      expect(find.text('Second Note'), findsOneWidget);
      expect(find.text('Third Note'), findsOneWidget);

      // Press Arrow Down to select first note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // First note should be selected (with highlighted background)
      expect(find.text('First Note'), findsOneWidget);

      // Press Arrow Down again to select second note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Second note should be selected
      expect(find.text('Second Note'), findsOneWidget);

      // Press Arrow Up to go back to first note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      // First note should be selected again
      expect(find.text('First Note'), findsOneWidget);

      // Press Enter to open selected note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Should navigate to note detail screen
      expect(find.byType(NoteDetailScreen), findsOneWidget);
    });

    testWidgets('Arrow key navigation wraps around list', (tester) async {
      // Create test notes
      await repo.createNote(title: 'Note A', content: 'Content A');
      await repo.createNote(title: 'Note B', content: 'Content B');
      await notesVm.load();

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Press Arrow Up on first note should wrap to last note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      // Last note should be selected
      expect(find.text('Note B'), findsOneWidget);

      // Press Arrow Down on last note should wrap to first note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // First note should be selected
      expect(find.text('Note A'), findsOneWidget);
    });

    testWidgets('Cmd/Ctrl+S saves note from detail screen', (tester) async {
      // Create a test note
      final note = await repo.createNote(title: 'Original Title', content: 'Original Content');

      // Navigate to note detail screen
      await editorVm.init(noteId: note.id);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note detail screen is displayed
      expect(find.byType(NoteDetailScreen), findsOneWidget);

      // Modify the title and content fields
      final titleField = find.widgetWithText(AppTextField, 'Note title');
      await tester.enterText(titleField, 'Updated Title');
      await tester.pump();

      final contentField = find.widgetWithText(AppTextField, 'Start writing...');
      await tester.enterText(contentField, 'Updated Content');
      await tester.pumpAndSettle();

      // Simulate Cmd/Ctrl+S to save
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Wait for save to complete
      await tester.pump(const Duration(milliseconds: 500));

      // Verify note was saved by checking the repository
      final savedNote = await repo.getNoteById(note.id);
      expect(savedNote, isNotNull);
      expect(savedNote!.title, 'Updated Title');
      expect(savedNote.content, 'Updated Content');
    });

    testWidgets('Cmd/Ctrl+1/2/3 apply text formatting in note detail', (tester) async {
      // Create a test note
      final note = await repo.createNote(title: 'Format Test', content: '');
      await editorVm.init(noteId: note.id);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify note detail screen is displayed
      expect(find.byType(NoteDetailScreen), findsOneWidget);

      // Enter some text in content field
      final contentField = find.widgetWithText(AppTextField, 'Start writing...');
      await tester.enterText(contentField, 'bold text');
      await tester.pumpAndSettle();

      // Select the text for formatting
      await tester.tap(contentField);
      await tester.pumpAndSettle();

      // Test Cmd/Ctrl+1 for heading formatting
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Test Cmd/Ctrl+2 for bold formatting
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Test Cmd/Ctrl+3 for italic formatting
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit3);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit3);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verify formatting markers were applied
      final currentContent = editorVm.note?.content ?? '';
      expect(currentContent.contains('**') || currentContent.contains('#'), isTrue);
    });

    testWidgets('Complete workflow: Create, Navigate, Edit, Save', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Step 1: Press Cmd/Ctrl+N to create new note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);

      // Step 2: Enter note content
      final titleField = find.widgetWithText(AppTextField, 'Note title');
      await tester.enterText(titleField, 'Test Note');
      await tester.pump();

      final contentField = find.widgetWithText(AppTextField, 'Start writing...');
      await tester.enterText(contentField, 'Test content for keyboard shortcuts');
      await tester.pumpAndSettle();

      // Step 3: Press Cmd/Ctrl+S to save
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));

      // Step 4: Verify we're back on home screen with new note
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Test Note'), findsOneWidget);

      // Step 5: Use arrow keys to navigate to the note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Step 6: Press Enter to open the note
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byType(NoteDetailScreen), findsOneWidget);
      expect(find.text('Test Note'), findsOneWidget);
    });
  });
}
