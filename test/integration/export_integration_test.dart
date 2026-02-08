import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/data/services/export_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ExportService exportService;
  late NoteModel testNote;

  setUp(() {
    exportService = ExportService();

    // Create a test note with title and content
    testNote = NoteModel(
      id: 1,
      title: 'Test Note Title',
      content: 'This is a test note with some content.\nIt has multiple lines.',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      updatedAt: DateTime(2024, 1, 16, 14, 20),
      isPinned: false,
      folderId: 'folder123',
    );
  });

  group('Single Note Export - Markdown Format', () {
    testWidgets('exports note to Markdown successfully', (tester) async {
      final result = await exportService.exportSingleNote(testNote, ExportFormat.markdown);

      // Verify export result metadata
      expect(result.itemCount, equals(1));
      expect(result.format, equals('markdown'));
      expect(result.filePath, endsWith('.md'));
      expect(result.filePath, contains('Test_Note_Title'));
    });

    testWidgets('exports note with only title to Markdown', (tester) async {
      final noteWithOnlyTitle = NoteModel(
        id: 2,
        title: 'Title Only Note',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(noteWithOnlyTitle, ExportFormat.markdown);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('markdown'));
      expect(result.filePath, endsWith('.md'));
    });

    testWidgets('exports note with only content to Markdown', (tester) async {
      final noteWithOnlyContent = NoteModel(
        id: 3,
        title: '',
        content: 'Content without title',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(noteWithOnlyContent, ExportFormat.markdown);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('markdown'));
      expect(result.filePath, endsWith('.md'));
    });
  });

  group('Single Note Export - TXT Format', () {
    testWidgets('exports note to plain text format', (tester) async {
      final result = await exportService.exportSingleNote(testNote, ExportFormat.txt);

      // Verify export result metadata
      expect(result.itemCount, equals(1));
      expect(result.format, equals('txt'));
      expect(result.filePath, endsWith('.txt'));
    });

    testWidgets('exports note with multiline content to TXT', (tester) async {
      final multilineNote = NoteModel(
        id: 4,
        title: 'Multiline Note',
        content: 'Line 1\nLine 2\nLine 3',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(multilineNote, ExportFormat.txt);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('txt'));
      expect(result.filePath, endsWith('.txt'));
    });
  });

  group('Single Note Export - PDF Format', () {
    testWidgets('exports note to PDF format', (tester) async {
      final result = await exportService.exportSingleNote(testNote, ExportFormat.pdf);

      // Verify export result metadata
      expect(result.itemCount, equals(1));
      expect(result.format, equals('pdf'));
      expect(result.filePath, endsWith('.pdf'));
    });

    testWidgets('exports empty note to PDF', (tester) async {
      final emptyNote = NoteModel(
        id: 5,
        title: '',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(emptyNote, ExportFormat.pdf);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('pdf'));
    });
  });

  group('Single Note Export - JSON Format', () {
    testWidgets('exports note to JSON with correct structure', (tester) async {
      final result = await exportService.exportSingleNote(testNote, ExportFormat.json);

      // Verify export result metadata
      expect(result.itemCount, equals(1));
      expect(result.format, equals('json'));
      expect(result.filePath, endsWith('.json'));
    });

    testWidgets('exports note with null optional fields to JSON', (tester) async {
      final noteWithoutOptionalFields = NoteModel(
        id: 6,
        title: 'Minimal Note',
        content: 'Content',
        createdAt: DateTime(2024, 1, 10),
        updatedAt: null,
        isPinned: false,
        folderId: null,
      );

      final result = await exportService.exportSingleNote(noteWithoutOptionalFields, ExportFormat.json);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('json'));
    });
  });

  group('Shareable Content Generation', () {
    testWidgets('generates shareable content with title and content', (tester) async {
      final content = await exportService.getShareableContent(testNote);

      // Verify title and content are both included
      expect(content, contains('Test Note Title'));
      expect(content, contains('This is a test note with some content.'));

      // Verify separator between title and content (double newline)
      expect(content, contains('\n\n'));
    });

    testWidgets('generates shareable content for note with only title', (tester) async {
      final titleOnlyNote = NoteModel(
        id: 7,
        title: 'Only Title',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(titleOnlyNote);

      expect(content, contains('Only Title'));
      expect(content, isNot(contains('\n\n')));
    });

    testWidgets('generates shareable content for note with only content', (tester) async {
      final contentOnlyNote = NoteModel(
        id: 8,
        title: '',
        content: 'Only content here',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(contentOnlyNote);

      expect(content, contains('Only content here'));
      expect(content, isNot(contains('\n\n')));
    });

    testWidgets('handles empty note for shareable content', (tester) async {
      final emptyNote = NoteModel(
        id: 9,
        title: '',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(emptyNote);

      expect(content, isEmpty);
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('handles special characters in note title', (tester) async {
      final specialCharNote = NoteModel(
        id: 10,
        title: 'Note with <special> & "characters"',
        content: 'Content here',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(specialCharNote, ExportFormat.markdown);

      expect(result.itemCount, equals(1));
      expect(result.filePath, isNotEmpty);
    });

    testWidgets('handles very long note title', (tester) async {
      final longTitleNote = NoteModel(
        id: 11,
        title: 'A' * 500,
        content: 'Content',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(longTitleNote, ExportFormat.txt);

      expect(result.itemCount, equals(1));
      expect(result.filePath, isNotEmpty);
    });

    testWidgets('handles multiline content correctly', (tester) async {
      final multilineNote = NoteModel(
        id: 12,
        title: 'Multiline Test',
        content: 'Line 1\nLine 2\nLine 3\nLine 4',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final markdownResult = await exportService.exportSingleNote(multilineNote, ExportFormat.markdown);
      final txtResult = await exportService.exportSingleNote(multilineNote, ExportFormat.txt);

      expect(markdownResult.itemCount, equals(1));
      expect(txtResult.itemCount, equals(1));
    });

    testWidgets('handles unicode characters in content', (tester) async {
      final unicodeNote = NoteModel(
        id: 13,
        title: 'Unicode Test',
        content: 'Hello 世界 🌍 Привет мир',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(unicodeNote, ExportFormat.markdown);

      expect(result.itemCount, equals(1));
      expect(result.filePath, isNotEmpty);
    });

    testWidgets('handles pinned notes correctly', (tester) async {
      final pinnedNote = NoteModel(
        id: 14,
        title: 'Pinned Note',
        content: 'This note is pinned',
        createdAt: DateTime.now(),
        isPinned: true,
      );

      final result = await exportService.exportSingleNote(pinnedNote, ExportFormat.json);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('json'));
    });

    testWidgets('handles notes with folder assignment', (tester) async {
      final folderNote = NoteModel(
        id: 15,
        title: 'Folder Note',
        content: 'In a folder',
        createdAt: DateTime.now(),
        isPinned: false,
        folderId: 'test_folder_123',
      );

      final result = await exportService.exportSingleNote(folderNote, ExportFormat.json);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('json'));
    });
  });

  group('Export Format Coverage', () {
    testWidgets('verifies all export formats are supported', (tester) async {
      final formats = [
        ExportFormat.markdown,
        ExportFormat.txt,
        ExportFormat.pdf,
        ExportFormat.json,
      ];

      for (final format in formats) {
        final result = await exportService.exportSingleNote(testNote, format);

        expect(result.itemCount, equals(1), reason: '$format export should succeed');
        expect(result.filePath, isNotEmpty, reason: '$format export should return file path');
        expect(result.format, equals(format.name), reason: '$format format name should match');
      }
    });

    testWidgets('verifies file extensions match formats', (tester) async {
      final formatExtensions = {
        ExportFormat.markdown: '.md',
        ExportFormat.txt: '.txt',
        ExportFormat.pdf: '.pdf',
        ExportFormat.json: '.json',
      };

      for (final entry in formatExtensions.entries) {
        final result = await exportService.exportSingleNote(testNote, entry.key);
        expect(result.filePath, endsWith(entry.value),
            reason: '${entry.key} should have ${entry.value} extension');
      }
    });
  });

  group('Timestamp Handling', () {
    testWidgets('handles notes with different timestamps', (tester) async {
      final oldNote = NoteModel(
        id: 16,
        title: 'Old Note',
        content: 'Created long ago',
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2021, 5, 15),
        isPinned: false,
      );

      final recentNote = NoteModel(
        id: 17,
        title: 'Recent Note',
        content: 'Just created',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
      );

      final oldResult = await exportService.exportSingleNote(oldNote, ExportFormat.json);
      final recentResult = await exportService.exportSingleNote(recentNote, ExportFormat.json);

      expect(oldResult.itemCount, equals(1));
      expect(recentResult.itemCount, equals(1));
    });

    testWidgets('handles notes with null updatedAt', (tester) async {
      final noUpdateNote = NoteModel(
        id: 18,
        title: 'Never Updated',
        content: 'Created but never modified',
        createdAt: DateTime.now(),
        updatedAt: null,
        isPinned: false,
      );

      final result = await exportService.exportSingleNote(noUpdateNote, ExportFormat.json);

      expect(result.itemCount, equals(1));
      expect(result.format, equals('json'));
    });
  });

  group('Multiple Notes Export (ZIP)', () {
    testWidgets('exports multiple notes to ZIP archive', (tester) async {
      final notes = [
        testNote,
        NoteModel(
          id: 19,
          title: 'Second Note',
          content: 'Another note content',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
        NoteModel(
          id: 20,
          title: 'Third Note',
          content: 'Third note here',
          createdAt: DateTime.now(),
          isPinned: true,
        ),
      ];

      final result = await exportService.exportMultipleNotes(notes, ExportFormat.markdown);

      expect(result.itemCount, equals(3));
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(result.filePath, contains('notes_markdown_3_'));
    });

    testWidgets('handles duplicate filenames in ZIP', (tester) async {
      final notes = [
        NoteModel(
          id: 21,
          title: 'Same Title',
          content: 'First note',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
        NoteModel(
          id: 22,
          title: 'Same Title',
          content: 'Second note',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
        NoteModel(
          id: 23,
          title: 'Same Title',
          content: 'Third note',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
      ];

      final result = await exportService.exportMultipleNotes(notes, ExportFormat.txt);

      expect(result.itemCount, equals(3));
      expect(result.format, equals('txt_zip'));
      expect(result.filePath, endsWith('.zip'));
    });

    testWidgets('throws error when exporting empty notes list', (tester) async {
      expect(
        () => exportService.exportMultipleNotes([], ExportFormat.markdown),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ZIP Export Formats', () {
    testWidgets('exports to all supported ZIP formats', (tester) async {
      final notes = [
        testNote,
        NoteModel(
          id: 24,
          title: 'Another Note',
          content: 'Content',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
      ];

      final formats = [
        ExportFormat.markdown,
        ExportFormat.txt,
        ExportFormat.pdf,
        ExportFormat.json,
      ];

      for (final format in formats) {
        final result = await exportService.exportMultipleNotes(notes, format);

        expect(result.itemCount, equals(2),
            reason: 'ZIP export for $format should include all notes');
        expect(result.format, equals('${format.name}_zip'),
            reason: 'ZIP export for $format should have correct format name');
        expect(result.filePath, endsWith('.zip'),
            reason: 'ZIP export for $format should have .zip extension');
      }
    });
  });
}
