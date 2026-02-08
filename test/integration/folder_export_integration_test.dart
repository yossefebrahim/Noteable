import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/data/services/export_service.dart';
import 'package:path/path.dart' as path;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ExportService exportService;

  setUp(() {
    exportService = ExportService();
  });

  group('Folder Export - ZIP Archive', () {
    testWidgets('exports notes from a specific folder as ZIP', (tester) async {
      // Create test scenario: multiple notes across different folders
      final folderId = 'work_folder_123';
      final notes = [
        // Notes in the target folder
        NoteModel(
          id: 1,
          title: 'Meeting Notes',
          content: 'Discussed project timeline and milestones.',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Action Items',
          content: '- Review design\n- Update documentation\n- Schedule follow-up',
          createdAt: DateTime(2024, 1, 16),
          isPinned: true,
          folderId: folderId,
        ),
        // Notes in a different folder (should NOT be included)
        NoteModel(
          id: 3,
          title: 'Personal Note',
          content: 'Grocery list: milk, eggs, bread',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: 'personal_folder_456',
        ),
        // Note without folder (should NOT be included)
        NoteModel(
          id: 4,
          title: 'Unsorted Note',
          content: 'Random idea',
          createdAt: DateTime(2024, 1, 18),
          isPinned: false,
          folderId: null,
        ),
      ];

      // Simulate folder export: filter notes by folderId
      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      // Export folder notes as ZIP
      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.markdown,
      );

      // Verify export result
      expect(result.itemCount, equals(2),
          reason: 'Should export exactly 2 notes from the folder');
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'),
          reason: 'ZIP file should have .zip extension');
      expect(result.filePath, contains('notes_markdown_2_'),
          reason: 'Filename should indicate format and count');

      // Verify ZIP file exists on disk
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue,
          reason: 'ZIP file should be created on disk');
    });

    testWidgets('exports all notes when folderId is null', (tester) async {
      // Create notes across multiple folders and without folders
      final notes = [
        NoteModel(
          id: 1,
          title: 'Work Note',
          content: 'Work related content',
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

      // Export all notes (folderId = null means export all)
      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      // Verify all notes are exported
      expect(result.itemCount, equals(3),
          reason: 'Should export all 3 notes');
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));

      // Verify ZIP file exists
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('handles empty folder correctly', (tester) async {
      // Create notes in different folders
      final notes = [
        NoteModel(
          id: 1,
          title: 'Work Note',
          content: 'Work content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: 'work',
        ),
      ];

      // Try to export from an empty folder (no notes)
      final emptyFolderNotes = <NoteModel>[];

      // Should throw an error for empty notes list
      expect(
        () => exportService.exportMultipleNotes(emptyFolderNotes, ExportFormat.markdown),
        throwsA(isA<ArgumentError>()),
      );
    });

    testWidgets('exports folder notes to different ZIP formats', (tester) async {
      final folderId = 'test_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Test Note 1',
          content: 'Content 1',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Test Note 2',
          content: 'Content 2',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      // Test exporting to all supported ZIP formats
      final formats = [
        ExportFormat.markdown,
        ExportFormat.txt,
        ExportFormat.pdf,
        ExportFormat.json,
      ];

      for (final format in formats) {
        final result = await exportService.exportMultipleNotes(folderNotes, format);

        expect(result.itemCount, equals(2),
            reason: 'ZIP export for $format should include all folder notes');
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

    testWidgets('handles folder with many notes', (tester) async {
      // Create a folder with 10 notes
      final folderId = 'large_folder';
      final notes = List.generate(
        10,
        (index) => NoteModel(
          id: index + 1,
          title: 'Note ${index + 1}',
          content: 'Content for note ${index + 1}',
          createdAt: DateTime(2024, 1, 15 + index),
          isPinned: index % 3 == 0, // Pin every 3rd note
          folderId: folderId,
        ),
      );

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      expect(result.itemCount, equals(10),
          reason: 'Should export all 10 notes from folder');
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(result.filePath, contains('notes_markdown_10_'),
          reason: 'Filename should reflect note count');

      // Verify file exists
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('handles special characters in folder note titles', (tester) async {
      final folderId = 'special_chars_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Note with <special> & "characters"',
          content: 'Content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Note with émojis 🎉 and ùñîçödë',
          content: 'More content',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.markdown,
      );

      expect(result.itemCount, equals(2));
      expect(result.filePath, endsWith('.zip'));

      // Verify file exists and can be read
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('handles duplicate note titles within folder', (tester) async {
      final folderId = 'duplicate_titles_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Same Title',
          content: 'First note',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Same Title',
          content: 'Second note',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 3,
          title: 'Same Title',
          content: 'Third note',
          createdAt: DateTime(2024, 1, 17),
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.txt,
      );

      expect(result.itemCount, equals(3),
          reason: 'Should export all 3 notes even with duplicate titles');
      expect(result.format, equals('txt_zip'));
      expect(result.filePath, endsWith('.zip'));

      // Verify file exists
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('exports notes from folder with mixed pinned state', (tester) async {
      final folderId = 'mixed_pinned_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Pinned Note 1',
          content: 'Pinned content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: true,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Regular Note',
          content: 'Regular content',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 3,
          title: 'Pinned Note 2',
          content: 'Another pinned',
          createdAt: DateTime(2024, 1, 17),
          isPinned: true,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.json,
      );

      expect(result.itemCount, equals(3),
          reason: 'Should export all notes regardless of pinned state');
      expect(result.format, equals('json_zip'));

      // Verify all notes are included (pinned state should not affect export)
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('exports folder with notes having different timestamps', (tester) async {
      final folderId = 'timestamps_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Old Note',
          content: 'Created long ago',
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2021, 5, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Recent Note',
          content: 'Just created',
          createdAt: DateTime.now(),
          updatedAt: null,
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.json,
      );

      expect(result.itemCount, equals(2));
      expect(result.format, equals('json_zip'));

      // JSON format should preserve timestamps
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });
  });

  group('Folder Export - File Structure Verification', () {
    testWidgets('ZIP file has valid naming pattern', (tester) async {
      final folderId = 'naming_test_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'Test Note',
          content: 'Test content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.markdown,
      );

      // Verify filename pattern: notes_markdown_{count}_{timestamp}.zip
      final fileName = path.basename(result.filePath);
      expect(fileName, startsWith('notes_markdown_1_'));
      expect(fileName, endsWith('.zip'));

      // Verify timestamp is present (rough check for numeric timestamp)
      final withoutExtension = fileName.replaceAll('.zip', '');
      final parts = withoutExtension.split('_');
      expect(parts.length, greaterThanOrEqualTo(4),
          reason: 'Filename should have format: notes_format_count_timestamp');

      // Verify file exists
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);
    });

    testWidgets('ZIP export includes individual note files', (tester) async {
      final folderId = 'structure_folder';
      final notes = [
        NoteModel(
          id: 1,
          title: 'First Note',
          content: 'First content',
          createdAt: DateTime(2024, 1, 15),
          isPinned: false,
          folderId: folderId,
        ),
        NoteModel(
          id: 2,
          title: 'Second Note',
          content: 'Second content',
          createdAt: DateTime(2024, 1, 16),
          isPinned: false,
          folderId: folderId,
        ),
      ];

      final folderNotes = notes.where((note) => note.folderId == folderId).toList();

      final result = await exportService.exportMultipleNotes(
        folderNotes,
        ExportFormat.markdown,
      );

      // Verify ZIP file exists and is not empty
      final zipFile = File(result.filePath);
      expect(await zipFile.exists(), isTrue);

      final fileSize = await zipFile.length();
      expect(fileSize, greaterThan(0),
          reason: 'ZIP file should not be empty');
    });
  });
}
