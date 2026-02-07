import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/core/constants/default_shortcuts.dart';
import 'package:noteable_app/core/models/shortcut_action.dart';
import 'package:noteable_app/core/models/shortcut_action.dart' show KeyboardShortcut;
import 'package:noteable_app/core/services/keyboard_shortcut_service.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/keyboard_shortcuts_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:noteable_app/presentation/widgets/shortcut_customization_dialog.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Shortcut Customization and Reset - End-to-End', () {
    late KeyboardShortcutService shortcutService;
    late KeyboardShortcutsProvider shortcutsProvider;
    late InMemoryNotesFeatureRepository repo;
    late NotesViewModel notesVm;
    late NoteEditorViewModel editorVm;

    setUp(() async {
      // Initialize shortcut service and provider
      shortcutService = KeyboardShortcutService();
      shortcutsProvider = KeyboardShortcutsProvider(shortcutService);

      // Initialize notes repository and view models
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
        getNote: GetNoteUseCase(repo),
        createNote: CreateNoteUseCase(repo),
        updateNote: UpdateNoteUseCase(repo),
        deleteNote: DeleteNoteUseCase(repo),
      );
      await notesVm.load();
    });

    Widget _buildApp() {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/note-detail', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/search', builder: (_, __) => const SizedBox()),
        ],
      );

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notesVm),
          ChangeNotifierProvider.value(value: editorVm),
          ChangeNotifierProvider.value(value: shortcutsProvider),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('Customize shortcut: Change Cmd/Ctrl+N to Cmd/Ctrl+T', (tester) async {
      // Verify default shortcut for newNote is Cmd/Ctrl+N
      final defaultShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(defaultShortcut, isNotNull);
      expect(defaultShortcut!.key, LogicalKeyboardKey.keyN);

      // Create new shortcut with Cmd/Ctrl+T
      final newShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyT,
        modifiers: {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.metaLeft},
        description: 'Create new note',
      );

      // Update the shortcut
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, newShortcut);

      // Verify the shortcut was updated
      final updatedShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(updatedShortcut, isNotNull);
      expect(updatedShortcut!.key, LogicalKeyboardKey.keyT);
      expect(updatedShortcut.modifiers, contains(LogicalKeyboardKey.controlLeft));
      expect(updatedShortcut.modifiers, contains(LogicalKeyboardKey.metaLeft));
    });

    testWidgets('Customized shortcut works in application', (tester) async {
      // First, customize the newNote shortcut to Cmd/Ctrl+T
      final customShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyT,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Create new note',
      );
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, customShortcut);

      // Build app with updated shortcuts
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Verify we're on home screen
      expect(find.text('Notes'), findsOneWidget);

      // Test the NEW shortcut (Cmd/Ctrl+T)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();

      // Verify navigation occurred (should go to /note-detail)
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('Conflict detection: Prevent duplicate shortcuts', (tester) async {
      // Get the default save shortcut (Cmd/Ctrl+S)
      final saveShortcut = shortcutsProvider.getShortcut(ShortcutAction.save);
      expect(saveShortcut, isNotNull);

      // Try to assign the same shortcut to newNote action
      final duplicateShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: saveShortcut!.key,
        modifiers: saveShortcut.modifiers,
        description: 'Create new note (CONFLICT)',
      );

      // Check for conflict
      final conflict = shortcutsProvider.getConflict(
        duplicateShortcut,
        excludeAction: ShortcutAction.newNote,
      );

      expect(conflict, isNotNull);
      expect(conflict!.action, ShortcutAction.save);
    });

    testWidgets('Reset to defaults: Restore original shortcuts', (tester) async {
      // Customize multiple shortcuts
      final customNewNote = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyT,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Create new note',
      );
      final customSearch = KeyboardShortcut(
        action: ShortcutAction.search,
        key: LogicalKeyboardKey.keyK,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Search notes',
      );

      shortcutsProvider.updateShortcut(ShortcutAction.newNote, customNewNote);
      shortcutsProvider.updateShortcut(ShortcutAction.search, customSearch);

      // Verify shortcuts were customized
      expect(
        shortcutsProvider.getShortcut(ShortcutAction.newNote)!.key,
        LogicalKeyboardKey.keyT,
      );
      expect(
        shortcutsProvider.getShortcut(ShortcutAction.search)!.key,
        LogicalKeyboardKey.keyK,
      );

      // Reset to defaults
      shortcutsProvider.resetToDefaults();

      // Verify default shortcuts are restored
      final restoredNewNote = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      final restoredSearch = shortcutsProvider.getShortcut(ShortcutAction.search);

      // newNote should be Cmd/Ctrl+N (default)
      expect(restoredNewNote, isNotNull);
      expect(restoredNewNote!.key, LogicalKeyboardKey.keyN);

      // search should be Cmd/Ctrl+F (default)
      expect(restoredSearch, isNotNull);
      expect(restoredSearch!.key, LogicalKeyboardKey.keyF);
    });

    testWidgets('Reset shortcuts: Verify all shortcuts match defaults', (tester) async {
      // Customize some shortcuts
      final customShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyZ,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Custom new note',
      );
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, customShortcut);

      // Get default shortcuts for comparison
      final defaultNewNote = DefaultShortcuts.all
          .firstWhere((s) => s.action == ShortcutAction.newNote);

      // Verify customized shortcut differs from default
      final currentShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(currentShortcut!.key, isNot(defaultNewNote.key));

      // Reset to defaults
      shortcutsProvider.resetToDefaults();

      // Verify all shortcuts match defaults
      for (final defaultShortcut in DefaultShortcuts.all) {
        final restored = shortcutsProvider.getShortcut(defaultShortcut.action);
        expect(restored, isNotNull);
        expect(restored!.key, defaultShortcut.key);
        expect(restored.description, defaultShortcut.description);
      }
    });

    testWidgets('Customization dialog: Key capture works correctly', (tester) async {
      final shortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote)!;
      var savedShortcut = shortcut;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: shortcutsProvider,
              child: ShortcutCustomizationDialog(
                shortcut: shortcut,
                onSave: (newShortcut) {
                  savedShortcut = newShortcut;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.text('New Note Shortcut'), findsOneWidget);
      expect(find.text('Tap to capture new shortcut'), findsOneWidget);

      // Tap to start capture
      await tester.tap(find.text('Tap to capture new shortcut'));
      await tester.pumpAndSettle();

      // Verify capture mode is active
      expect(find.text('Press keys now...'), findsOneWidget);

      // Simulate pressing Cmd+T
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();

      // Verify captured combination is displayed
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Cmd+T') == true,
        ),
        findsOneWidget,
      );

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify shortcut was saved
      expect(savedShortcut.key, LogicalKeyboardKey.keyT);
      expect(savedShortcut.modifiers, contains(LogicalKeyboardKey.metaLeft));
    });

    testWidgets('Customization dialog: Conflict warning appears', (tester) async {
      // Get existing save shortcut
      final saveShortcut = shortcutsProvider.getShortcut(ShortcutAction.save)!;

      // Open dialog for newNote shortcut
      final newNoteShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote)!;
      KeyboardShortcut? savedShortcut;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: shortcutsProvider,
              child: ShortcutCustomizationDialog(
                shortcut: newNoteShortcut,
                onSave: (newShortcut) {
                  savedShortcut = newShortcut;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to start capture
      await tester.tap(find.text('Tap to capture new shortcut'));
      await tester.pumpAndSettle();

      // Press keys that match the save shortcut (Cmd/Ctrl+S)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();

      // Verify conflict warning appears
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('This shortcut is already used for') == true,
        ),
        findsOneWidget,
      );

      // Verify Save button is disabled (due to conflict)
      final saveButton = find.widgetWithText(FilledButton, 'Save');
      final saveButtonWidget = tester.widget<FilledButton>(saveButton);
      expect(saveButtonWidget.onPressed, isNull);
    });

    testWidgets('Multiple shortcut updates work correctly', (tester) async {
      // Customize multiple shortcuts at once
      final updates = <ShortcutAction, KeyboardShortcut>{
        ShortcutAction.newNote: KeyboardShortcut(
          action: ShortcutAction.newNote,
          key: LogicalKeyboardKey.keyT,
          modifiers: {LogicalKeyboardKey.metaLeft},
          description: 'New note',
        ),
        ShortcutAction.search: KeyboardShortcut(
          action: ShortcutAction.search,
          key: LogicalKeyboardKey.keyK,
          modifiers: {LogicalKeyboardKey.metaLeft},
          description: 'Search',
        ),
      };

      shortcutsProvider.updateShortcuts(updates);

      // Verify all updates were applied
      final newNoteShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      final searchShortcut = shortcutsProvider.getShortcut(ShortcutAction.search);

      expect(newNoteShortcut!.key, LogicalKeyboardKey.keyT);
      expect(searchShortcut!.key, LogicalKeyboardKey.keyK);
    });

    testWidgets('Remove shortcut and re-add it', (tester) async {
      // Remove the newNote shortcut
      shortcutsProvider.removeShortcut(ShortcutAction.newNote);

      // Verify it's removed
      expect(
        shortcutsProvider.getShortcut(ShortcutAction.newNote),
        isNull,
      );

      // Re-add it
      final newShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyN,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Create new note',
      );
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, newShortcut);

      // Verify it's restored
      final restored = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(restored, isNotNull);
      expect(restored!.key, LogicalKeyboardKey.keyN);
    });

    testWidgets('Customization complete workflow', (tester) async {
      // 1. Verify initial state (defaults)
      final initialShortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(initialShortcut!.key, LogicalKeyboardKey.keyN);

      // 2. Customize the shortcut
      final customShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyT,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'Create new note',
      );
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, customShortcut);

      // 3. Verify customization
      final customized = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(customized!.key, LogicalKeyboardKey.keyT);

      // 4. Test the customized shortcut works in the app
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);

      // 5. Reset to defaults
      shortcutsProvider.resetToDefaults();

      // 6. Verify defaults restored
      final restored = shortcutsProvider.getShortcut(ShortcutAction.newNote);
      expect(restored!.key, LogicalKeyboardKey.keyN);
    });

    testWidgets('Escape key cancels shortcut capture', (tester) async {
      final shortcut = shortcutsProvider.getShortcut(ShortcutAction.newNote)!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: shortcutsProvider,
              child: ShortcutCustomizationDialog(
                shortcut: shortcut,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to start capture
      await tester.tap(find.text('Tap to capture new shortcut'));
      await tester.pumpAndSettle();
      expect(find.text('Press keys now...'), findsOneWidget);

      // Press Escape to cancel
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verify we're back to non-capturing state
      expect(find.text('Tap to capture new shortcut'), findsOneWidget);
    });
  });

  group('Shortcut Provider Edge Cases', () {
    late KeyboardShortcutService shortcutService;
    late KeyboardShortcutsProvider shortcutsProvider;

    setUp(() {
      shortcutService = KeyboardShortcutService();
      shortcutsProvider = KeyboardShortcutsProvider(shortcutService);
    });

    testWidgets('Provider notifies listeners when shortcut changes', (tester) async {
      var notificationCount = 0;
      shortcutsProvider.addListener(() {
        notificationCount++;
      });

      // Update a shortcut
      final customShortcut = KeyboardShortcut(
        action: ShortcutAction.newNote,
        key: LogicalKeyboardKey.keyT,
        modifiers: {LogicalKeyboardKey.metaLeft},
        description: 'New note',
      );
      shortcutsProvider.updateShortcut(ShortcutAction.newNote, customShortcut);

      expect(notificationCount, greaterThan(0));
    });

    testWidgets('Provider notifies listeners when reset', (tester) async {
      var notificationCount = 0;
      shortcutsProvider.addListener(() {
        notificationCount++;
      });

      // Reset to defaults
      shortcutsProvider.resetToDefaults();

      expect(notificationCount, greaterThan(0));
    });
  });
}
