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

  group('Performance Test - Large Note Collections', () {
    static const int largeNoteCount = 100;
    static const int veryLargeNoteCount = 150;
    static const Duration maxAcceptableDuration = Duration(seconds: 10);

    testWidgets('exports 100 notes with varying content lengths in reasonable time',
        (tester) async {
      final notes = _generateNotesWithVaryingContent(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of $largeNoteCount notes should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports 100 notes to TXT format in reasonable time',
        (tester) async {
      final notes = _generateNotesWithVaryingContent(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.txt,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('txt_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'TXT export of $largeNoteCount notes should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports 100 notes to JSON format in reasonable time',
        (tester) async {
      final notes = _generateNotesWithVaryingContent(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.json,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('json_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'JSON export of $largeNoteCount notes should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports 150 notes without memory issues', (tester) async {
      final notes = _generateNotesWithVaryingContent(veryLargeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(veryLargeNoteCount));
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of $veryLargeNoteCount notes should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports notes with very long content without crashes',
        (tester) async {
      final notes = _generateNotesWithVeryLongContent(50);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(50));
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of 50 notes with very long content should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('handles duplicate titles efficiently in large collection',
        (tester) async {
      final notes = _generateNotesWithDuplicateTitles(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.txt,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('txt_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of $largeNoteCount notes with duplicate titles should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports mixed pinned and unpinned notes efficiently',
        (tester) async {
      final notes = _generateMixedPinnedNotes(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.json,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('json_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of $largeNoteCount mixed pinned notes should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('exports notes with special characters efficiently',
        (tester) async {
      final notes = _generateNotesWithSpecialCharacters(largeNoteCount);

      final stopwatch = Stopwatch()..start();

      final result = await exportService.exportMultipleNotes(
        notes,
        ExportFormat.markdown,
      );

      stopwatch.stop();

      expect(result.itemCount, equals(largeNoteCount));
      expect(result.format, equals('markdown_zip'));
      expect(result.filePath, endsWith('.zip'));
      expect(
        stopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason:
            'Export of $largeNoteCount notes with special characters should complete in less than ${maxAcceptableDuration.inSeconds} seconds',
      );
    });

    testWidgets('compares export performance across formats', (tester) async {
      final notes = _generateNotesWithVaryingContent(largeNoteCount);

      final markdownStopwatch = Stopwatch()..start();
      await exportService.exportMultipleNotes(notes, ExportFormat.markdown);
      markdownStopwatch.stop();

      final txtStopwatch = Stopwatch()..start();
      await exportService.exportMultipleNotes(notes, ExportFormat.txt);
      txtStopwatch.stop();

      final jsonStopwatch = Stopwatch()..start();
      await exportService.exportMultipleNotes(notes, ExportFormat.json);
      jsonStopwatch.stop();

      expect(
        markdownStopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason: 'Markdown export should complete in reasonable time',
      );
      expect(
        txtStopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason: 'TXT export should complete in reasonable time',
      );
      expect(
        jsonStopwatch.elapsed,
        lessThan(maxAcceptableDuration),
        reason: 'JSON export should complete in reasonable time',
      );
    });
  });
}

List<NoteModel> _generateNotesWithVaryingContent(int count) {
  final notes = <NoteModel>[];
  final now = DateTime.now();

  for (var i = 1; i <= count; i++) {
    final contentLength = i % 5; // Vary content length: 0 to 4 paragraphs
    final content = List.generate(
      contentLength + 1,
      (index) => 'Paragraph ${index + 1} of note $i with some content.',
    ).join('\n');

    notes.add(
      NoteModel(
        id: i,
        title: 'Note $i',
        content: content,
        createdAt: now.subtract(Duration(days: count - i)),
        updatedAt: now.subtract(Duration(days: count - i ~/ 2)),
        isPinned: i % 10 == 0,
        folderId: i % 3 == 0 ? 'folder_${i % 5}' : null,
      ),
    );
  }

  return notes;
}

List<NoteModel> _generateNotesWithVeryLongContent(int count) {
  final notes = <NoteModel>[];
  final now = DateTime.now();

  for (var i = 1; i <= count; i++) {
    final longContent = List.generate(
      100,
      (index) => 'This is line ${index + 1} of note $i with substantial content. '
          'It includes enough text to test performance with larger content sizes.',
    ).join('\n');

    notes.add(
      NoteModel(
        id: i,
        title: 'Long Content Note $i',
        content: longContent,
        createdAt: now,
        isPinned: false,
      ),
    );
  }

  return notes;
}

List<NoteModel> _generateNotesWithDuplicateTitles(int count) {
  final notes = <NoteModel>[];
  final now = DateTime.now();

  for (var i = 1; i <= count; i++) {
    notes.add(
      NoteModel(
        id: i,
        title: 'Shared Title', // Same title for all notes
        content: 'Unique content for note $i',
        createdAt: now,
        isPinned: false,
      ),
    );
  }

  return notes;
}

List<NoteModel> _generateMixedPinnedNotes(int count) {
  final notes = <NoteModel>[];
  final now = DateTime.now();

  for (var i = 1; i <= count; i++) {
    notes.add(
      NoteModel(
        id: i,
        title: 'Note $i',
        content: 'Content for note $i',
        createdAt: now,
        isPinned: i % 3 == 0, // Every third note is pinned
      ),
    );
  }

  return notes;
}

List<NoteModel> _generateNotesWithSpecialCharacters(int count) {
  final notes = <NoteModel>[];
  final now = DateTime.now();
  final specialTitles = [
    'Note with <special> & "characters"',
    'Note with/slashes\\',
    'Note with:colons and |pipes|',
    'Note with?question*marks',
    'Note with"quotes" and\'apostrophes\'',
    'Note 世界 with unicode',
    'Note with emoji 🌍🚀',
  ];

  for (var i = 1; i <= count; i++) {
    notes.add(
      NoteModel(
        id: i,
        title: '${specialTitles[i % specialTitles.length]} $i',
        content: 'Content with special chars: <>&"\'/\\|?* 世界 🌍',
        createdAt: now,
        isPinned: false,
      ),
    );
  }

  return notes;
}
