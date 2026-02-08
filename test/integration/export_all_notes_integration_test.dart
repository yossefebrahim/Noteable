import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/data/services/export_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ExportService exportService;

  setUp(() {
    exportService = ExportService();
  });

  group('Export All Notes - ZIP Archive', () {
    testWidgets('exports all notes across multiple folders as ZIP', (tester) async {
      // Create test scenario: notes across multiple folders and without folders
      final allNotes = [
        // Notes in work folder
        NoteModel(
          id: 1,
          title: 'Work Meeting Notes',
          content: 'Discussed Q1 goals and milestones.',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'work_folder_123',
        ),
        NoteModel(
          id: 2,
          title: 'Work Action Items',
          content: '- Review design\n- Update docs',
          createdAt: DateTime(2024, 1, 16),
          isPinned: true,
          folderId: 'work_folder_123',
        ),
        // Notes in personal folder
        NoteModel(
          id: 3,
          title: 'Personal Note',
          content: 'Grocery list: milk, eggs, bread',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: 'personal_folder_456',
        ),
        // Notes without folder (unsorted)
        NoteModel(
          id: 4,
          title: 'Unsorted Note',
          content: 'Random idea for later',
          createdAt: DateTime(2024, 1, 18),
          isPinned: false,
          folderId: null,
        ),
        // Another note in work folder
        NoteModel(
          id: 5,
          title: 'Project Timeline',
          content: 'Q1 deliverables due March 31',
          createdAt: DateTime(2024, 1, 19),
          isPinned: false,
          folderId: 'work_folder_123',
        ),
      ];

      // Export all notes as ZIP (simulating exportAllNotes use case)
      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.markdown,
      );

      // Verify export result includes ALL notes from all folders
      expect(result.itemCount, equals(5),
          reason: 'Should export all 5 notes across all folders');
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'),
          reason: 'ZIP file should have .zip extension');
      expect(result.filePath, contains('notes_markdown_5_'),
          reason: 'Filename should indicate total note count');

      // Verify ZIP file exists on disk
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue,
          reason: 'ZIP file should be created on disk');
    });

    testWidgets('exports all notes to different ZIP formats', (tester) async {
      // Create notes across multiple folders
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Work Note',
          content: 'Work content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'work',
        ),
        NoteModel(
          id: 2,
          title: 'Personal Note',
          content: 'Personal content',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'personal',
        ),
        NoteModel(
          id: 3,
          title: 'Unsorted Note',
          content: 'No folder',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: null,
        ),
      ];

      // Test exporting to all supported ZIP formats
      final formats = [
        ExportFormat.markdown,
        ExportFormat.txt,
        ExportFormat.pdf,
        ExportFormat.json,
      ];

      for (final format in formats) {
        final result = await exportService.exportMultipleNotes(allNotes, format);

        expect(result.itemCount, equals(3),
            reason: 'ZIP export for $format should include ALL notes');
        expect(result.format, equals('${format.name}_zip'));
        expect(result.filePath, endsWith('.zip'));

        // Verify file exists
        final zipFile = File(result.filePath);
        expect(await zipFile.exists(), isTrue,
            reason: 'ZIP file for $format should exist');

        // Clean up the file
        await zipFile.delete();
      }
    });

    testWidgets('handles empty database correctly for export all', (tester) async {
      // Empty database - no notes to export
      final emptyNotes = <NoteModel>[];

      // Should throw an error when trying to export empty notes list
      expect(
        () => exportService.exportMultipleNotes(emptyNotes, ExportFormat.markdown),
        throwsA(isA<ArgumentError>()),
        reason: 'Export all notes should fail with empty database',
      );
    });

    testWidgets('handles database with only unsorted notes', (tester) async {
      // All notes without folder assignment
      final unsortedNotes = [
        NoteModel(
          id: 1,
          title: 'Idea 1',
          content: 'First unsorted note',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: null,
        ),
        NoteModel(
          id: 2,
          title: 'Idea 2',
          content: 'Second unsorted note',
          createdAt: DateTime(2024, 1, 16),
          isPinned: true,
          folderId: null,
        ),
        NoteModel(
          id: 3,
          title: 'Idea 3',
          content: 'Third unsorted note',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        unsortedNotes,
        ExportFormat.markdown,
      );

      expect(result.itemCount, equals(3),
          reason: 'Should export all unsorted notes');
      expect(result.format, equals('markdown_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('handles large database with many folders', (tester) async {
      // Create notes across 5 different folders
      final folderIds = [
        'folder_1',
        'folder_2',
        'folder_3',
        'folder_4',
        'folder_5',
      ];

      final allNotes = <NoteModel>[];
      var noteId = 1;

      for (final folderId in folderIds) {
        // Add 3 notes per folder
        for (var i = 0; i < 3; i++) {
          allNotes.add(NoteModel(
            id: noteId++,
            title: 'Note ${allNotes.length + 1}',
            content: 'Content in $folderId',
            createdAt: DateTime(2024, 1, 15 + allNotes.length),
            isPinned: noteId % 5 == 0,
            folderId: folderId,
          ));
        }
      }

      // Add some unsorted notes
      allNotes.add(NoteModel(
        id: noteId++,
        title: 'Unsorted 1',
        content: 'No folder',
        createdAt: DateTime(2024, 1, 20),
        isPinned: false,
        folderId: null,
      ));
      allNotes.add(NoteModel(
        id: noteId++,
        title: 'Unsorted 2',
        content: 'Also no folder',
        createdAt: DateTime(2024, 1, 21),
        isPinned: false,
        folderId: null,
      ));

      // Total: 15 folder notes + 2 unsorted = 17 notes
      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.txt,
      );

      expect(result.itemCount, equals(17),
          reason: 'Should export all 17 notes across all folders');
      expect(result.format, equals('txt_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('preserves all note metadata in JSON format', (tester) async {
      // Create notes with various metadata states
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Pinned Note in Work',
          content: 'Work content',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          updatedAt: DateTime(2024, 1, 16, 14, 20),
          isPinned: true,
          folderId: 'work',
        ),
        NoteModel(
          id: 2,
          title: 'Unpinned Note without Folder',
          content: 'Personal content',
          createdAt: DateTime(2024, 1, 17, 9, 0),
          updatedAt: null,
          isPinned: false,
          folderId: null,
        ),
        NoteModel(
          id: 3,
          title: 'Regular Note',
          content: 'Regular content',
          createdAt: DateTime(2024, 1, 18, 16, 45),
          updatedAt: DateTime(2024, 1, 18, 16, 45),
          isPinned: false,
          folderId: 'personal',
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.json,
      );

      // Verify all notes are included
      expect(result.itemCount, equals(3));
      expect(result.format, equals('json_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);

      // Verify file size is reasonable (JSON with metadata should have content)
      final fileSize = await zipFile.length();
      expect(fileSize, greaterThan(100),
          reason: 'JSON ZIP should contain metadata for all notes');
    });
  });

  group('Export All Notes - Metadata Verification', () {
    testWidgets('includes notes with mixed pinned states', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Pinned Note 1',
          content: 'Pinned content 1',
          createdAt: DateTime(2024, 1, 15),
          isPinned: true,
          folderId: 'folder_a',
        ),
        NoteModel(
          id: 2,
          title: 'Regular Note',
          content: 'Regular content',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'folder_b',
        ),
        NoteModel(
          id: 3,
          title: 'Pinned Note 2',
          content: 'Pinned content 2',
          createdAt: DateTime(2024, 1, 17),
          isPinned: true,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.json,
      );

      expect(result.itemCount, equals(3),
          reason: 'Should include all notes regardless of pinned state');
      expect(result.format, equals('json_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('includes notes with different timestamps', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Very Old Note',
          content: 'From 2020',
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2020, 1, 2),
          isPinned: false,
          folderId: 'old',
        ),
        NoteModel(
          id: 2,
          title: 'Recent Note',
          content: 'From 2024',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'new',
        ),
        NoteModel(
          id: 3,
          title: 'No Updated At',
          content: 'Never modified',
          createdAt: DateTime(2024, 1, 17),
          updatedAt: null,
          isPinned: false,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.json,
      );

      expect(result.itemCount, equals(3));
      expect(result.format, equals('json_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('includes notes with special characters in titles across folders', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Note with <special> & "characters"',
          content: 'Content 1',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'folder_special',
        ),
        NoteModel(
          id: 2,
          title: 'Note with émojis 🎉 and ùñîçödë',
          content: 'Content 2',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'folder_unicode',
        ),
        NoteModel(
          id: 3,
          title: 'Note without folder but with symbols: @#\$%',
          content: 'Content 3',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.markdown,
      );

      expect(result.itemCount, equals(3));
      expect(result.filePath, endsWith('.zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('handles duplicate titles across different folders', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Same Title',
          content: 'In work folder',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'work',
        ),
        NoteModel(
          id: 2,
          title: 'Same Title',
          content: 'In personal folder',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'personal',
        ),
        NoteModel(
          id: 3,
          title: 'Same Title',
          content: 'No folder',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.txt,
      );

      expect(result.itemCount, equals(3),
          reason: 'Should export all notes with duplicate titles');
      expect(result.format, equals('txt_zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });
  });

  group('Export All Notes - ZIP Structure', () {
    testWidgets('ZIP file has valid naming pattern for all notes', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'Note 1',
          content: 'Content 1',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'folder_a',
        ),
        NoteModel(
          id: 2,
          title: 'Note 2',
          content: 'Content 2',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'folder_b',
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.markdown,
      );

      // Verify filename pattern: notes_markdown_{count}_{timestamp}.zip
      expect(result.filePath, contains('notes_markdown_2_'));
      expect(result.filePath, endsWith('.zip'));

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('ZIP file is not empty and contains data', (tester) async {
      final allNotes = [
        NoteModel(
          id: 1,
          title: 'First Note',
          content: 'First content with some text',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'folder_1',
        ),
        NoteModel(
          id: 2,
          title: 'Second Note',
          content: 'Second content with more text',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: 'folder_2',
        ),
        NoteModel(
          id: 3,
          title: 'Third Note',
          content: 'Third content',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: null,
        ),
      ];

      final result = await exportService.exportMultipleNotes(
        allNotes,
        ExportFormat.markdown,
      );

      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);

      final fileSize = await zipFile.length();
      expect(fileSize, greaterThan(0),
          reason: 'ZIP file should contain exported note data');
    });
  });
}
